{:user {:dependencies [[org.clojure/tools.namespace  "0.2.9"]
                       [slamhound "1.5.5"]]
        :plugins [[cider/cider-nrepl "0.8.2"]]
        :repl-options  {:init-ns user}
        :source-paths  [#=(eval (str (System/getProperty "user.home") "/.lein"))]}}
