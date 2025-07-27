require 'csv'

class AttendanceAnalyzerService
  REQUIRED_HEADERS = %w[date start finish]
  LEGAL_WORK_HOURS = 8.0

  attr_reader :errors

  def initialize(csv_data)
    utf8_data = csv_data.force_encoding('Shift_JIS').encode('UTF-8', invalid: :replace, undef: :replace)
    @csv = CSV.parse(utf8_data, headers: true)
    @errors = []  # スキップ理由をここに貯める
  end

  def analyze
    unless valid_headers?
      raise StandardError, "CSVヘッダーが不正です。'date', 'start', 'finish' の3列が必要です"
    end

    @csv.each_with_index.map do |row, index|
      begin
        start_time = Time.parse(row['start'])
        end_time = Time.parse(row['finish'])
        duration = ((end_time - start_time) / 3600).round(2)
        overtime = [duration - LEGAL_WORK_HOURS, 0].max.round(2)

        {
          date: row['date'],
          start: start_time.strftime('%H:%M'),
          end: end_time.strftime('%H:%M'),
          hours: duration,
          overtime: overtime
        }
      rescue => e
        @errors << "第#{index + 2}行目でエラー: #{e.message}（内容: #{row.to_h}）"
        nil
      end
    end.compact
  end

  def monthly_summary
    analyze_data = analyze
  
    analyze_data.group_by { |r| Date.parse(r[:date]).strftime('%Y-%m') }
                .transform_values { |rows| rows.sum { |r| r[:hours] } }
  end

  def monthly_average
    analyze_data = analyze
  
    grouped = analyze_data.group_by { |r| Date.parse(r[:date]).strftime('%Y-%m') }
  
    grouped.transform_values do |rows|
      total = rows.sum { |r| r[:hours] }
      count = rows.size
      average = count > 0 ? (total / count.to_f).round(2) : 0
      {
        total: total.round(2),
        average: average
      }
    end
  end

  def monthly_attendance_days
    analyze_data = analyze
  
    grouped = analyze_data.group_by { |r| Date.parse(r[:date]).strftime('%Y-%m') }
  
    grouped.transform_values do |rows|
      unique_days = rows.map { |r| r[:date] }.uniq
      unique_days.count
    end
  end

  def monthly_overtime_hours
    analyze.group_by { |r| Date.parse(r[:date]).strftime('%Y-%m') }
           .transform_values { |rows| rows.sum { |r| r[:overtime] } }
  end

  private

  def valid_headers?
    (REQUIRED_HEADERS - @csv.headers.map(&:to_s)).empty?
  end
end
