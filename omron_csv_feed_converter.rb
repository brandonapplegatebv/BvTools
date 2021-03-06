require 'csv'

class OmronCsvFeedConverter

	def initialize
		@products = {}
    @categories = []
    read_csv
    @feed = File.open('omron_feed.xml', 'w')
	end

	def create_categories
		@products.each do |k,v|
    	@categories << v[0]
    end
    @categories.uniq!
  end

  def read_csv
		CSV.foreach('omron_feed.csv', headers: true) do |row|
			external_id = row['ExternalID']
			name = row['Name']
			category_external_id = row['CategoryExternalId']
			pdp_url = row['ProductPageUrl']
			image_url = row['ImageUrl']
			upc = row['UPC']
			mpn = row['ManufacturerPartNumber']

			@products["#{name}"] = ["#{category_external_id}", "#{pdp_url}", "#{image_url}", "#{external_id}", "#{upc}", "#{mpn}"]
		end
	end

	def create_header
		@feed << "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<Feed xmlns=\"http://www.bazaarvoice.com/xs/PRR/ProductFeed/5.6\" name=\"#{@input.downcase}\" incremental=\"false\" extractDate=\"2013-08-16T12:00:00.000000\">\n"
	end

	def get_input
		@input = gets.chomp.downcase
	end

	def build_name(input)
    "<Name>#{input.split(/[-_ ]/).map { |x| x.capitalize }.join(' ')}</Name>"
	end

	def build_externalid(input)
		"<ExternalId>#{input.downcase.gsub(' ', '')}</ExternalId>"
	end

	def build_catergory_external_id(input)
  	"<CategoryExternalId>#{input.downcase.gsub(' ', '_')}</CategoryExternalId>"
  end

  def build_product_page_url(input)
    "<ProductPageUrl>#{input}</ProductPageUrl>"
	end

	def build_image_url(input)
    "<ImageUrl><![CDATA[#{input}]]></ImageUrl>"
  end

  def build_upc(input)
  	"<UPCs>
  	      <UPC>#{input.gsub(' ', '')}</UPC>
  	    </UPCs>"
  end

  def build_mpn(input)
  	"<ManufacturerPartNumbers>
          <ManufacturerPartNumber>#{input}</ManufacturerPartNumber>
        </ManufacturerPartNumbers>"
  end

  def build_description(input)
		"<Description>#{input}</Description>"
	end

	def build_value(input)
		"<Value>#{input.downcase.gsub(' ', '_')}</Value>"
	end

	def get_brand
		puts 'Enter Brand name:'
  	get_input
  end

  def build_brands
  	@feed << "    <Brands>
  	  <Brand>
  		  #{build_externalid(@input)}
  		  #{build_name(@input)}
  	  </Brand>
    </Brands>\n"
  end

  def build_categories
  	@feed << "    <Categories>\n"
  	@categories.each do |x|
  	  @feed << "      <Category>\n"
  	  @feed << "        #{build_externalid(x)}
  	    #{build_name(x)}
      </Category>\n"
    end
  	@feed << "    </Categories>\n"
  end

  def build_sub_products(name, array)
  	"      <Product>
  		#{build_externalid(array[3])}
  		#{build_name(name)}
  		#{build_description(name)}
  		#{build_product_page_url(array[1])}
  		#{build_image_url(array[2])}
  		#{build_catergory_external_id(array[0])}
  		#{build_mpn(array[5])}
  		#{build_upc(array[4])}
  		<Attributes>
       <Attribute id=\"BV_FE_FAMILY\">
         <Value>#{array[0]}</Value>
       </Attribute>
      </Attributes>
     </Product>\n"
  end

  def build_sub_products_with_expand(name, array)
  	"      <Product>
  		#{build_externalid(array[3])}
  		#{build_name(name)}
  		#{build_description(name)}
  		#{build_product_page_url(array[1])}
  		#{build_image_url(array[2])}
  		#{build_catergory_external_id(array[0])}
  		<Attributes>
       <Attribute id=\"BV_FE_FAMILY\">
         <Value>#{array[0]}</Value>
       </Attribute>
		   <Attribute id=\"BV_FE_EXPAND\">
         <Value>BV_FE_FAMILY:#{array[0]}</Value>
       </Attribute>
      </Attributes>
     </Product>\n"
  end

  def build_products
  	@feed <<"    <Products>\n"
  	@products.each do |k,v|
  		@feed << build_sub_products(k,v)
  	end
  	@feed << "    </Products>\n"
  	@feed << "</Feed>"
  end
end

x = OmronCsvFeedConverter.new

x.create_categories
x.get_brand
x.create_header
x.build_brands
x.build_categories
x.build_products



