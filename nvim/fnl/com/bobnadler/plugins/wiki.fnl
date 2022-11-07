(module com.bobnadler.plugins.wiki
  {autoload {nvim aniseed.nvim}})

(set nvim.g.vimwiki_list
     [{:path "~/Dropbox/vimwiki/"
       :syntax "markdown"
       :ext ".md"}])
