class Checkout
  def initialize(promotional_rules = [])
    @promotional_rules = promotional_rules
    @products = []
  end

  def scan(product)
    @products << product
    true
  end

  def total
    (-apply_promotional_rules.to_f + raw_total.to_f).round(2)
  end

  private
  attr_reader :promotional_rules, :discount_percentage

  def raw_total
    price_for(@products)
  end

  def price_for(products)
    products.map(&:price).inject(0, :+)
  end

  def apply_promotional_rules
    promotional_rules.each.inject(0) do |discount, rule|
      if rule[:name] == :cumulative
        cumulative(rule)
      end

      if rule[:name] == :discount
        discount += discount(rule)
      end

      discount
    end
  end

  def discount(rule)
    if raw_total >= rule[:treshold]
      raw_total * rule[:discount]
    else
      0
    end
  end

  def cumulative(rule)
    products = find_products_by(rule[:product_code])
    if products.size >= rule[:treshold]
      @products = @products.map do |product|
        if product.product_code == rule[:product_code]
          product.price = rule[:new_price_per_item].to_f
        end
        product
      end
    end
  end

  def find_products_by(product_code)
    @products.select { |product| product.product_code == product_code }
  end
end