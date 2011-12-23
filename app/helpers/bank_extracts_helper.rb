module BankExtractsHelper
  def up_down(bl)
    content_tag :td do
     arrow_up(bl) + concat(tag("br"))+ arrow_down(bl)
      
    end
  end

  def arrow_up(bl)
    unless bl.first?
      concat(link_to image_tag('datatable/demi_sort_asc.png'),
        up_organism_bank_account_bank_extract_bank_extract_line_path(@organism,@bank_account, @bank_extract,bl.id),
        method: :post)
    else
      concat('')
    end
  end

  def arrow_down(bl)
    unless bl.last?
      concat(link_to image_tag('datatable/demi_sort_desc.png'),
        down_organism_bank_account_bank_extract_bank_extract_line_path(@organism,@bank_account, @bank_extract,bl.id),
        method: :post)
    else
      concat('')
    end
  end
end
