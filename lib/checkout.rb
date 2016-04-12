class Checkout
  def initialize(promotional_rules = [])
    @promotional_rules = promotional_rules
    @products = []
  end

  def scan(product)
    @products << product
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
    cumulative if cumulative_rule
    discount_rule ? discount : 0
  end

  def discount_rule
    rule_for :discount
  end

  def cumulative_rule
    rule_for :cumulative
  end

  def rule_for(rule_name)
    promotional_rules.select do |rule|
      rule[:name] == rule_name
    end.first
  end

  def discount
    if raw_total >= discount_rule[:treshold]
      raw_total * discount_rule[:discount]
    else
      0
    end
  end

  def cumulative
    decorate_products_by(cumulative_rule[:product_code]) do |product, count|
      if count >= cumulative_rule[:treshold]
        product.price = cumulative_rule[:new_price_per_item].to_f
      end
    end
  end

  def decorate_products_by(product_code, &block)
    @products.map! do |product|
      if product.product_code == product_code
        yield(product, count_products_by(product_code))
      end
      product
    end
  end

  def count_products_by(product_code)
    @products.count { |product| product.product_code == product_code }
  end
end