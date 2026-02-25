if Rails.application.config.active_job.queue_adapter == :good_job
  Rails.application.configure do
    config.good_job.execution_mode = :external
    config.good_job.poll_interval = 5
    config.good_job.max_threads = 30
    config.good_job.queues = [
      # Format: "queue_name:thread_count"
      # Map Shoryuken queue names to GoodJob queues with priority ordering
      "+#{AppSettings.fetch(:aws_sqs_high_priority_queue_name)}:10",
      "+#{AppSettings.fetch(:aws_sqs_medium_priority_queue_name)}:10",
      "+#{AppSettings.fetch(:aws_sqs_default_queue_name)}:5",
      "+#{AppSettings.fetch(:aws_sqs_outbound_calls_queue_name)}:5",
      "+#{AppSettings.fetch(:aws_sqs_low_priority_queue_name)}:3",
      "+#{AppSettings.fetch(:aws_sqs_long_running_queue_name)}:1",
      "+#{AppSettings.fetch(:aws_sqs_scheduler_queue_name)}:1",
      "+*:5" # catch-all for any other queues
    ].join(";")
  end
end
