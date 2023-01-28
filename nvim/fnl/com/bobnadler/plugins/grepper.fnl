(module com.bobnadler.plugins.grepper
  {autoload {utils com.bobnadler.utils}})

;; Search for the current selection
(utils.nmap "gs" "<plug>(GrepperOperator)")
(utils.xmap "gs" "<plug>(GrepperOperator)")
