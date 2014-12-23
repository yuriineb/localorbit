module PackingLabels
  describe Generator do
    subject { described_class }

    context "#perform interaction testing" do
      let(:request)     { double :request, base_url: base_url }
      let(:base_url)    { "the base url" }
      let(:orders)      { "some orders"  }
      let(:order_infos) { double "A list of order infos"  }
      let(:labels)      { double "A list of labels"  }
      let(:pages)       { double "A list of pages"  }
      let(:pdf_result)  { "the pdf result" }

      it "works by creating order infos, labels, and then pages" do
        expect(PackingLabels::OrderInfo).to receive(:make_order_infos).with(orders:orders,host:base_url).and_return(order_infos)
        expect(PackingLabels::Label).to receive(:make_labels).with(order_infos).and_return(labels)
        expect(PackingLabels::Page).to receive(:make_pages).with(labels).and_return(pages)

        expect(TemplatedPdfGenerator).to receive(:generate_pdf).with(
          request: request,
          template: "avery_labels/labels",
          pdf_settings: TemplatedPdfGenerator::ZeroMargins.merge({ page_size: "letter" }),
          locals: {
            params: { pages: pages }
          }
        ).and_return(pdf_result)

        pdf_result = subject.generate(orders: orders, request: request) # from HEAD

        expect(pdf_result).to eq("the pdf result")
      end
    end
  end
end
