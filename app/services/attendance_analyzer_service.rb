require 'csv'

class AttendanceAnalyzerService
  def initialize(csv_data)
    utf8_data = csv_data.force_encoding('Shift_JIS').encode('UTF-8', invalid: :replace, undef: :replace)
    @csv = CSV.parse(utf8_data, headers: true)
  end

  def analyze
    @csv.map do |row|
      Rails.logger.info "Processing row: #{row.inspect}"
      start_time = Time.parse(row['start'])
      end_time = Time.parse(row['finish'])
      duration = ((end_time - start_time) / 3600).round(2)

      {
        date: row['date'],
        start: start_time.strftime('%H:%M'),
        end: end_time.strftime('%H:%M'),
        hours: duration
      }
    end
  end
end
