local utils = import 'mixin-utils/utils.libsonnet';

(import 'dashboard-utils.libsonnet') {
  grafanaDashboards+::
    {
      'loki-deletion.json':
        ($.dashboard('Loki / Deletion', uid='deletion'))
        .addClusterSelectorTemplates(false)
        .addRow(
          ($.row('Headlines') +
           {
             height: '100px',
             showTitle: false,
           })
          .addPanel(
            $.panel('Number of Pending Requests') +
            $.statPanel('sum(loki_compactor_pending_delete_requests_count{%s})' % $.namespaceMatcher(), format='none')
          )
          .addPanel(
            $.panel('Oldest Pending Request Age') +
            $.statPanel('max(loki_compactor_oldest_pending_delete_request_age_seconds{%s})' % $.namespaceMatcher(), format='dtdurations')
          )
        )
        .addRow(
          $.row('Churn')
          .addPanel(
            $.panel('Delete Requests Received / Day') +
            $.queryPanel('sum(increase(loki_compactor_delete_requests_received_total{%s}[1d]))' % $.namespaceMatcher(), 'received'),
          )
          .addPanel(
            $.panel('Delete Requests Processed / Day') +
            $.queryPanel('sum(increase(loki_compactor_delete_requests_processed_total{%s}[1d]))' % $.namespaceMatcher(), 'processed'),
          )
        ).addRow(
          $.row('Failures')
          .addPanel(
            $.panel('Failures in Loading Delete Requests / Hour') +
            $.queryPanel('sum(increase(loki_compactor_load_pending_requests_attempts_total{status="fail", %s}[1h]))' % $.namespaceMatcher(), 'failures'),
          )
        ),
    },
}
