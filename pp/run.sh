export POWERPIPE_DATABASE=postgres://steampipe:e616_4d8c_abe4@steampipe:9193/steampipe
pwd
#powerpipe mod install github.com/sysco-middleware/oci-powerpipe-diff-mod
#powerpipe mod install github.com/turbot/steampipe-mod-oci-compliance
#powerpipe mod list
powerpipe benchmark run oci_compliance.benchmark.cis_v200 --export=csv --export=json --export=html