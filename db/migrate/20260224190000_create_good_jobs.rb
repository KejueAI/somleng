class CreateGoodJobs < ActiveRecord::Migration[8.0]
  def change
    enable_extension "pgcrypto"

    create_table :good_jobs, id: :uuid do |t|
      t.text :queue_name
      t.integer :priority
      t.jsonb :serialized_params
      t.datetime :scheduled_at
      t.datetime :performed_at
      t.datetime :finished_at
      t.text :error

      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false

      t.uuid :active_job_id
      t.text :concurrency_key
      t.text :cron_key
      t.uuid :retried_good_job_id
      t.datetime :cron_at
      t.uuid :batch_id
      t.uuid :batch_callback_id
      t.boolean :is_discrete
      t.integer :executions_count
      t.text :job_class
      t.integer :error_event, limit: 2
      t.text :labels, array: true
      t.uuid :locked_by_id
      t.datetime :locked_at
    end

    add_index :good_jobs, :queue_name
    add_index :good_jobs, :scheduled_at
    add_index :good_jobs, :active_job_id
    add_index :good_jobs, :concurrency_key
    add_index :good_jobs, :cron_key
    add_index :good_jobs, :finished_at
    add_index :good_jobs, [:priority, :created_at],
              order: { priority: "ASC NULLS LAST", created_at: :asc },
              where: "finished_at IS NULL",
              name: :index_good_jobs_jobs_on_priority_created_at_when_unfinished
    add_index :good_jobs, [:batch_id], where: "batch_id IS NOT NULL"
    add_index :good_jobs, [:batch_callback_id], where: "batch_callback_id IS NOT NULL"
    add_index :good_jobs, :labels, using: :gin, where: "labels IS NOT NULL"
    add_index :good_jobs, [:locked_by_id],
              where: "locked_by_id IS NOT NULL",
              name: :index_good_jobs_on_locked_by_id

    create_table :good_job_batches, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :description
      t.jsonb :serialized_properties
      t.text :on_finish
      t.text :on_success
      t.text :on_discard
      t.text :callback_queue_name
      t.integer :callback_priority
      t.datetime :enqueued_at
      t.datetime :discarded_at
      t.datetime :finished_at
    end

    create_table :good_job_executions, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.uuid :active_job_id, null: false
      t.text :job_class
      t.text :queue_name
      t.jsonb :serialized_params
      t.datetime :scheduled_at
      t.datetime :finished_at
      t.text :error
      t.integer :error_event, limit: 2
      t.text :error_backtrace, array: true
      t.uuid :process_id
      t.interval :duration
    end

    add_index :good_job_executions, [:active_job_id, :created_at],
              name: :index_good_job_executions_on_active_job_id_and_created_at

    create_table :good_job_processes, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.jsonb :state
      t.integer :lock_type, limit: 2
    end

    create_table :good_job_settings, id: :uuid do |t|
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
      t.text :key
      t.jsonb :value
    end

    add_index :good_job_settings, :key, unique: true
  end
end
