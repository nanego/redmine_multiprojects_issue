module MultiprojectsIssueHelper

  # TODO: simplify this method or split it into multiple parts
  def multiprojects_issue_project_tree_options(projects, options = {})
    s = ''
    project_tree(projects) do |project, level|
      name_prefix = (level > 0 ? '&nbsp;' * 2 * level + '&#187; ' : '').html_safe
      tag_options = {:value => project.id}
      if project == options[:selected] || (options[:selected].respond_to?(:include?) && options[:selected].include?(project))
        tag_options[:selected] = 'selected'
      else
        tag_options[:selected] = nil
      end
      if options[:disabled].respond_to?(:include?) && options[:disabled].include?(project)
        tag_options[:disabled] = 'disabled'
      else
        tag_options[:disabled] = nil
      end
      # TODO: the following two lines made my brain explode
      tag_options.merge!(yield(project)) if block_given?
      s << content_tag('option', name_prefix + h(project), tag_options)
    end
    s.html_safe
  end

end
