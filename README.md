# Epp

## Examples

```
bundle exec epp render -e 'ServerAlias <%= $test %>' --values_file values.pp
```

```
bundle exec epp render -e 'ServerAlias <%= $test %>' --values '{test => "test"}' 
```

```
echo 'ServerAlias <%= $test %>' | bundle exec epp render --values '{test => hello}'
```

```
facter > data.yml
bundle exec epp render test.epp --facts data.yaml 
```

```
facter > data.yml
bundle exec epp render test.epp test2.epp --facts data.yaml 
```
