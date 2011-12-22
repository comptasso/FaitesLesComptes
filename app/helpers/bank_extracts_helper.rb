module BankExtractsHelper
  def up_down(blid)
    content_tag :td do
      concat(link_to image_tag('datatable/sort_asc.png'),
        up_organism_bank_account_bank_extract_bank_extract_line_path(@organism,@bank_account, @bank_extract,blid),
        method: :post) +
       concat(tag("br"))+
        concat(link_to image_tag('datatable/sort_desc.png'),
        down_organism_bank_account_bank_extract_bank_extract_line_path(@organism,@bank_account, @bank_extract,blid),
        method: :post)

    end
  end
end
