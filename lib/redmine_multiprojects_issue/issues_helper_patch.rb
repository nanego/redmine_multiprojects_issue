require_dependency 'issues_helper'

module IssuesHelper
  unless instance_methods.include?(:show_detail_with_multiproject_issues)
    # Returns the textual representation of a single journal detail
    # Core properties are 'attr', 'attachment' or 'cf' : this patch specify how to display 'projects' journal details
    # 'projects' property is introduced by this plugin
    def show_detail_with_multiproject_issues(detail, no_html=false, options={})

      # Process custom 'projects' property
      if detail.property == 'projects'

        value = detail.value
        old_value = detail.old_value

        if value.present? # projects added to the issue

          value = value.split(',')
          list = content_tag("span", h(value.join(', ')), class: "journal_projects_details", data: {detail_id: detail.id}, style: value.size>1 ? "display:none;":"")
          if value.size>1 # no links if there is only one value
            link = link_to l(:label_details).downcase, "#", class: "show_journal_details", data: {detail_id: detail.id}
            linkHide = link_to l(:label_hide_details).downcase, "#", class: "hide_journal_details", data: {detail_id: detail.id}
          end

          if no_html
            value.join(', ')
          else
            details = "(#{link}#{linkHide}#{list})"
            "#{value.size} #{value.size>1 ? l(:text_journal_projects_added) : l(:text_journal_project_added)} #{details}".html_safe
          end

        elsif old_value.present? # projects removed from the issue

          old_value = old_value.split(',')
          list = content_tag("del", h(old_value.join(', ')), class: "journal_projects_details", data: {detail_id: detail.id}, style: old_value.size>1 ? "display:none;":"")
          if old_value.size>1 # no links if there is only one old value
            link = link_to l(:label_details).downcase, "#", class: "show_journal_details", data: {detail_id: detail.id}
            linkHide = link_to l(:label_hide_details).downcase, "#", class: "hide_journal_details", data: {detail_id: detail.id}
          end

          if no_html
            old_value.join(', ')
          else
            details = "(#{link}#{linkHide}#{list})" unless no_html
            "#{old_value.size} #{old_value.size>1 ? l(:text_journal_projects_deleted) : l(:text_journal_project_deleted)} #{details}".html_safe
          end

        end

      else
        # Process standard properties like 'attr', 'attachment' or 'cf'
        show_detail_without_multiproject_issues(detail, no_html, options)
      end

    end
    alias_method_chain :show_detail, :multiproject_issues
  end
end
