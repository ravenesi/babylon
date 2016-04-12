require_relative '../../lib/checkout'
require_relative '../../lib/product'

RSpec.describe Checkout, type: :model do
  before(:each) do
    @product1 = create_product(
      product_code: '001', name: 'Lavender heart', price: 9.25
    )
    @product2 = create_product(
      product_code: '002', name: 'Personalised cufflinks', price: 45.00
    )
    @product3 = create_product(
      product_code: '003', name: 'Kids T-shirt', price: 19.95
    )
  end

  describe '#initalize' do
    subject { described_class }

    it 'verify parameter assignment' do
      promotional_rules = [{
        treshold: 60,
        discount: -0.1
      }]

      co = Checkout.new(promotional_rules)

      expect(co.instance_variable_get(:@promotional_rules)).to eq(promotional_rules)
    end

    it 'verify default parameter assignment' do
      co = Checkout.new

      expect(co.instance_variable_get(:@promotional_rules)).to eq([])
      expect(co.instance_variable_get(:@products)).to eq([])
    end
  end

  describe '#scan' do
    it 'verify product scan order' do
      co = Checkout.new
      co.scan(@product1)
      co.scan(@product2)
      co.scan(@product3)

      expect(co.instance_variable_get(:@products)).to eq([
        @product1, @product2, @product3
      ])
    end
  end

  context '#total' do
    it 'verify sumarize products price for 2 rounds in checkout' do
      product2 = @product2.dup
      product2.price = 10.111

      co = Checkout.new
      co.scan(@product1)
      co.scan(product2)
      co.scan(@product3)

      expect(co.total).to eq(39.31)
    end

    context 'promotional rules applied' do
      describe 'threshold rule' do
        it 'will apply' do
          promotional_rules = [{
            name: :discount,
            treshold: 60,
            discount: 0.1
          }]

          co = Checkout.new(promotional_rules)
          co.scan(@product1)
          co.scan(@product2)
          co.scan(@product3)
          price = co.total

          expect(price).to be 66.78
        end
      end

      describe 'cumulative purchase rule' do
        it 'will apply' do
          promotional_rules = [{
            name: :cumulative,
            treshold: 2,
            product_code: '001',
            new_price_per_item: 8.5
          }]

          co = Checkout.new(promotional_rules)
          co.scan(@product1)
          co.scan(@product3)
          co.scan(@product1)
          price = co.total

          expect(price).to be 36.95
        end
      end

      describe 'cumulative and treshold purchase rule' do
        it 'will apply' do
          promotional_rules = [{
            name: :cumulative,
            treshold: 2,
            product_code: '001',
            new_price_per_item: 8.5
          },{
            name: :discount,
            treshold: 60,
            discount: 0.1
          }]

          co = Checkout.new(promotional_rules)
          co.scan(@product1)
          co.scan(@product2)
          co.scan(@product1)
          co.scan(@product3)
          price = co.total

          expect(price).to be 73.76
        end
      end
    end
  end
end

def create_product(product_code:, name:, price:)
  Product.new(
    product_code: product_code,
    name: name,
    price: price
  )
end