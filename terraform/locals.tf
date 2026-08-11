locals {
  base_tags = merge(
    {
      Application        = var.project_name
      System             = "StoreProducts"
      Environment        = var.environment
      Owner              = var.owner
      ManagedBy          = "Terraform"
      Repository         = var.repository
      CostCenter         = var.cost_center
      Criticality        = lower(var.criticality)
      DataClassification = lower(var.data_classification)
      BackupRequired     = "true"
      Region             = var.location
    },
    var.additional_tags,
  )

  platform_tags = merge(local.base_tags, { Workload = "platform" })
  store_tags    = merge(local.base_tags, { Workload = "store" })
  products_tags = merge(local.base_tags, { Workload = "products" })
}
