module Quickbooks
  class Bill
    class << self
      def create_bill (order, po_transactions, child_transactions, session, config)

        # Create supplier org if necessary
        if order.products.first.organization.qb_org_id.nil?
          retry_cnt = 0
          loop do
            begin
              org = order.products.first.organization
              result = Quickbooks::Vendor.create_vendor(org, session)
              org.qb_org_id = result.id
              org.save!(validate: false)
              failed = false
            rescue => e
              puts e
              failed = true
              retry_cnt = retry_cnt + 1
            end
            break if !failed || retry_cnt > 10
          end
        end

        bill = Quickbooks::Model::Bill.new
        bill.vendor_id = order.products.first.organization.qb_org_id
        bill.txn_date = Date
        bill.doc_number = order.order_number

        if config.consolidated_supplier_item_id.nil?
          po_transactions.each do |trans|
            @product = Product.find(trans.product_id)

            # Create items if necessary
            itm_result = nil
            if @product.qb_item_id.nil?
              retry_cnt = 0
              loop do
                begin
                  prd = @product
                  itm_result = Quickbooks::Item.create_item(prd, session, config)
                  if !itm_result.nil?
                    prd.qb_item_id = itm_result.id
                    prd.skip_validation = true
                    prd.save!(validate: false)
                    failed = false
                  end
                rescue => e
                  puts e
                  failed = true
                  retry_cnt = retry_cnt + 1
                end
                break if !failed || retry_cnt > 10
              end
            end
          end
        end

        product_price_total = 0
        product_qty_total = 0
        product_count = 0

        child_transactions.flatten.each do |trans|
          if config.consolidated_supplier_item_id.nil?
            if trans.transaction_type == "SO"
              buyer_name = Order.find(trans.order_id).organization.name
              desc = "#{buyer_name} : #{@product.name}"
              qb_item = @product.qb_item_id

              line_item = Quickbooks::Model::BillLineItem.new
              line_item.amount = trans.net_price * trans.quantity
              line_item.description = desc
              line_item.item_based_expense_item! do |detail|
                detail.unit_price = trans.net_price
                detail.quantity = trans.quantity
                detail.item_id = qb_item # Item ID here
              end
              bill.line_items << line_item
            end
          else
            if (trans.transaction_type == "SO" || trans.transaction_type == "SHRINK")
              product_price_total = product_price_total + trans.net_price
              product_qty_total = product_qty_total + trans.quantity
              product_count = product_count + 1
            end
          end
        end

        if !config.consolidated_supplier_item_id.nil?
          line_item = Quickbooks::Model::BillLineItem.new
          line_item.amount = (product_price_total/product_count) * product_qty_total
          line_item.description = config.consolidated_supplier_item_name
          line_item.item_based_expense_item! do |detail|
            detail.unit_price = (product_price_total/product_count)
            detail.quantity = product_qty_total
            detail.item_id = config.consolidated_supplier_item_id # Item ID here
          end
          bill.line_items << line_item
        end

        service = Quickbooks::Service::Bill.new
        service.company_id = session[:qb_realm_id]
        access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, session[:qb_token], session[:qb_secret])
        service.access_token = access_token

        created_invoice = service.create(bill)
      end
    end
  end
end