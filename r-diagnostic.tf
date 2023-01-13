data "azurerm_monitor_diagnostic_categories" "main" {
  count = local.enabled ? 1 : 0

  resource_id = var.resource_id
}

resource "azurerm_monitor_diagnostic_setting" "main" {
  count = local.enabled ? 1 : 0

  name               = local.diag_name
  target_resource_id = var.resource_id

  storage_account_id             = local.storage_id
  log_analytics_workspace_id     = local.log_analytics_id
  log_analytics_destination_type = local.log_analytics_destination_type
  eventhub_authorization_rule_id = local.eventhub_authorization_rule_id
  eventhub_name                  = local.eventhub_name

  dynamic "log" {
    for_each = local.logs

    content {
      category = log.key
      enabled  = log.value.enabled

      retention_policy {
        enabled = log.value.enabled && log.value.retention_days != null
        days    = log.value.enabled ? log.value.retention_days : 0
      }
    }
  }

  dynamic "metric" {
    for_each = local.metrics

    content {
      category = metric.key
      enabled  = metric.value.enabled

      retention_policy {
        enabled = metric.value.enabled && metric.value.retention_days != null
        days    = metric.value.enabled ? metric.value.retention_days : 0
      }
    }
  }

  #lifecycle {
  #  ignore_changes = [log_analytics_destination_type]
  #}
}
