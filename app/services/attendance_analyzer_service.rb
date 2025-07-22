require 'csv'

class AttendanceAnalyzerService
  REQUIRED_HEADERS = %w[date start finish]

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

        {
          date: row['date'],
          start: start_time.strftime('%H:%M'),
          end: end_time.strftime('%H:%M'),
          hours: duration
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

  private

  def valid_headers?
    (REQUIRED_HEADERS - @csv.headers.map(&:to_s)).empty?
  end
end
