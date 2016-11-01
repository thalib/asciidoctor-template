module AsciidoctorPdfExtensions

  def layout_running_content periphery, doc, opts = {}
	  if doc.attr? 'date'
		  doc.set_attr 'document-date', doc.attr('date')
	  end
	  super
  end

  def layout_title_page doc
    return unless doc.header? && !doc.notitle
    prev_bg_image = @page_bg_image
    prev_bg_color = @page_bg_color

    puts doc.attr('date')
    if (bg_image = resolve_background_image doc, @theme, 'title-page-background-image')
      @page_bg_image = (bg_image == 'none' ? nil : bg_image)
    end
    if (bg_color = resolve_theme_color :title_page_background_color)
      @page_bg_color = bg_color
    end
    # NOTE a new page will already be started if the cover image is a PDF
    start_new_page unless page_is_empty?
    @page_bg_image = prev_bg_image if bg_image
    @page_bg_color = prev_bg_color if bg_color

    # IMPORTANT this is the first page created, so we need to set the base font
    font @theme.base_font_family, size: @theme.base_font_size

    # QUESTION allow aligment per element on title page?
    title_align = @theme.title_page_align.to_sym

    # TODO disallow .pdf as image type
    if (logo_image_path = (doc.attr 'title-logo-image', @theme.title_page_logo_image))
      puts Asciidoctor::Pdf::Converter::ImageAttributeValueRx
      if (logo_image_path.include? ':') && logo_image_path =~ Asciidoctor::Pdf::Converter::ImageAttributeValueRx
        logo_image_path = $1
        logo_image_attrs = (Asciidoctor::AttributeList.new $2).parse ['alt', 'width', 'height']
      else
        logo_image_attrs = {}
      end
      # HACK quick fix to resolve image path relative to theme
      unless doc.attr? 'title-logo-image'
        logo_image_path = Asciidoctor::Pdf::ThemeLoader.resolve_theme_asset logo_image_path, (doc.attr 'pdf-stylesdir')
      end
      logo_image_attrs['target'] = logo_image_path
      logo_image_attrs['align'] ||= (@theme.title_page_logo_align || title_align.to_s)
      logo_image_top = (logo_image_attrs['top'] || @theme.title_page_logo_top)
      # FIXME delegate to method to convert page % to y value
      logo_image_top = [(page_height - page_height * (logo_image_top.to_i / 100.0)), bounds.absolute_top].min
      float do
        @y = logo_image_top
        # FIXME add API to Asciidoctor for creating blocks like this (extract from extensions module?)
        image_block = ::Asciidoctor::Block.new doc, :image, content_model: :empty, attributes: logo_image_attrs
        # FIXME prevent image from spilling to next page
        # QUESTION should we shave off margin top/bottom?
        convert_image image_block
      end
    end

    # TODO prevent content from spilling to next page
    theme_font :title_page do
      doctitle = doc.doctitle partition: true
      if (title_top = @theme.title_page_logotitle_top)
        # FIXME delegate to method to convert page % to y value
        @y = [(page_height - page_height * (title_top.to_i / 100.0)), bounds.absolute_top].min
      end
      move_down (@theme.title_page_logotitle_margin_top || 0)
      if doc.attr? 'logotitle'
        theme_font :title_page_logotitle do
          layout_heading doc.attr('logotitle'),
            align: title_align,
            margin: 0,
            line_height: @theme.title_page_logotitle_line_height
        end
      end
      if doc.attr? 'title_address'
        theme_font :title_page_title_address do
          doc.attr('title_address').split(":").each do |address_line|
            layout_prose address_line,
              align: title_align,
              margin: 0,
              normalize: false
          end
        end
      end
      if (title_top = @theme.title_page_title_top)
        # FIXME delegate to method to convert page % to y value
        @y = [(page_height - page_height * (title_top.to_i / 100.0)), bounds.absolute_top].min
      end

      move_down (@theme.title_page_title_margin_top || 0)
      theme_font :title_page_title do
        layout_heading doctitle.main,
          align: title_align,
          margin: 0,
          line_height: @theme.title_page_title_line_height
      end
      move_down (@theme.title_page_title_margin_bottom || 0)
      if doctitle.subtitle
        move_down (@theme.title_page_subtitle_margin_top || 0)
        theme_font :title_page_subtitle do
          layout_heading doctitle.subtitle,
            align: title_align,
            margin: 0,
            line_height: @theme.title_page_subtitle_line_height
        end
        move_down (@theme.title_page_subtitle_margin_bottom || 0)
      end
      if doc.attr? 'authors'
        move_down (@theme.title_page_authors_margin_top || 0)
        theme_font :title_page_authors do
          # TODO add support for author delimiter
          layout_prose doc.attr('authors'),
            align: title_align,
            margin: 0,
            normalize: false
        end
        move_down (@theme.title_page_authors_margin_bottom || 0)
      end
      revision_info = [(doc.attr? 'revnumber') ? %(#{doc.attr 'version-label'} #{doc.attr 'revnumber'}) : nil, (doc.attr 'revdate')].compact
      unless revision_info.empty?
        move_down (@theme.title_page_revision_margin_top || 0)
        theme_font :title_page_revision do
          revision_text = revision_info * (@theme.title_page_revision_delimiter || ', ')
          layout_prose revision_text,
            align: title_align,
            margin: 0,
            normalize: false
        end
        move_down (@theme.title_page_revision_margin_bottom || 0)
      end

      if (title_top = @theme.title_page_customerinfo_top)
        # FIXME delegate to method to convert page % to y value
        @y = [(page_height - page_height * (title_top.to_i / 100.0)), bounds.absolute_top].min
      end

      if doc.attr? 'customer'
	theme_font :title_page_customerinfo do
	  layout_heading "customer/partner",
            align: title_align,
            margin: 0,
            line_height: @theme.title_page_logotitle_line_height
        end
        move_down (@theme.title_page_revision_margin_bottom || 0)
	theme_font :title_page_customerinfo do
	  layout_heading doc.attr('customer'),
            align: title_align,
            margin: 0,
            line_height: @theme.title_page_logotitle_line_height
        end
      end
    end
  end
end

Asciidoctor::Pdf::Converter.prepend AsciidoctorPdfExtensions
  
