require 'spec_helper'
require 'controllers/api/v1/shared_examples/products'

describe Api::V1::ProductsController do

  it_behaves_like 'products search api'

end
