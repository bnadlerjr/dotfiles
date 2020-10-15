{:user {:dependencies [[pjstadig/humane-test-output  "0.9.0"]]
        :injections [(require 'pjstadig.humane-test-output)
                     (pjstadig.humane-test-output/activate!)]
        :plugins [[lein-try "0.4.3"]]
        :signing {:gpg-key "FA541587"}}}
