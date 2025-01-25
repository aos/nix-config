function fish_jj_prompt --description "Print jj prompt"
  if not command -sq jj
    return 1
  end

  if not jj root --quiet &>/dev/null
    return 1
  end

  jj log --ignore-working-copy --no-pager --no-graph --color=always \
    -r @ -T ps1_repo_info
end

function fish_vcs_prompt --description "Print all vcs prompts"
  # Try jj first
  fish_jj_prompt $argv
  or fish_git_prompt $argv
  or fish_hg_prompt $argv
  or fish_fossil_prompt $argv
end
