module TypusHelper

  ##
  # Applications list on the dashboard
  #
  def applications

    returning(String.new) do |html|

      Typus.applications.each do |app|

        available = Typus.application(app).map do |resource|
                      resource if @current_user.resources.include?(resource)
                    end
        next if available.compact.empty?

        html << <<-HTML
<table>
<tr>
<th colspan="2">#{app}</th>
</tr>
        HTML

        available.compact.each do |model|
          description = Typus.module_description(model)
          html << <<-HTML
<tr class="#{cycle('even', 'odd')}">
<td>#{link_to t(model.titleize.pluralize), send("admin_#{model.tableize}_path")}<br /><small>#{t(description)}</small></td>
<td class="right"><small>
#{link_to t('Add'), send("new_admin_#{model.tableize.singularize}_path") if @current_user.can_perform?(model, 'create')}
</small></td>
</tr>
          HTML
        end

        html << <<-HTML
</table>
        HTML

      end

    end

  end

  ##
  # Resources (wich are not models) on the dashboard.
  #
  def resources

    available = Typus.resources.map do |resource|
                  resource if @current_user.resources.include?(resource)
                end
    return if available.compact.empty?

    returning(String.new) do |html|

      html << <<-HTML
<table>
<tr>
<th colspan="2">#{t('Resources')}</th>
</tr>
      HTML

      available.compact.each do |resource|

        html << <<-HTML
<tr class="#{cycle('even', 'odd')}">
<td>#{link_to t(resource.titleize), "#{Typus::Configuration.options[:prefix]}/#{resource.underscore}"}</td>
<td align="right" style="vertical-align: bottom;"></td>
</tr>
        HTML

      end

      html << <<-HTML
</table>
      HTML

    end

  end

  def typus_block(*args)
    options = args.extract_options!
    file = [ 'admin', options[:model], options[:location], options[:partial] ].compact.join('/')
    render :partial => file rescue nil
  end

  def page_title(action = params[:action])
    crumbs = [ Typus::Configuration.options[:app_name] ]
    crumbs << @resource[:class_name_humanized].pluralize if @resource
    crumbs << I18n.t(action.humanize, :default => action.humanize) unless %w( index ).include?(action)
    return crumbs.compact.map { |x| x }.join(' &rsaquo; ')
  end

  def header
    <<-HTML
<h1>#{Typus::Configuration.options[:app_name]} 
    <small>#{link_to t("View site"), root_path, :target => 'blank' rescue ''}</small></h1>
    HTML
  end

  def login_info(user = @current_user)
    <<-HTML
<ul>
  <li>#{t("Logged as")} #{link_to user.full_name(:display_role => true), edit_admin_typus_user_path(user.id)}</li>
  <li>#{link_to t("Sign out"), admin_sign_out_path}</li>
</ul>
    HTML
  end

  def display_flash_message
    return if flash.empty?
    flash_type = flash.keys.first
    returning(String.new) do |html|
      html << <<-HTML
<div id="flash" class="#{flash_type}"><p>#{flash[flash_type]}</p></div>
      HTML
    end
  end

  def typus_message(message, html_class = 'notice')
    <<-HTML
<div id="flash" class="#{html_class}">
  <p>#{message}</p>
</div>
    HTML
  end

  def locales(uri = admin_set_locale_path)
    return unless Typus.locales.many?
    returning(String.new) do |html|
      html << <<-HTML
<ul>
  <li>#{t("Set language")}:</li>
      HTML
      Typus.locales.each do |locale|
        html << <<-HTML
  <li><a href="#{uri}?#{locale.last}">#{locale.first}</a></li>
        HTML
      end
      html << "</ul>\n"
    end
  end

end