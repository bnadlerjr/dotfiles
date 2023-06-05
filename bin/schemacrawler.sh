./schemacrawler-16.19.9-bin/bin/schemacrawler.sh \
        --server=postgresql \
        --user=postgres \
        --host=localhost \
        --port=5432 \
        --info-level=maximum \
        --command script \
        --script-language python \
        --script ./schemacrawler-16.19.9-bin/mermaid.py \
        $1
