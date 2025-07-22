require 'csv'

class AttendanceUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attr_accessor :csv_file

  REQUIRED_HEADERS = %w[date start finish]

  validates :csv_file, presence: true
  validate :valid_csv_format
  validate :valid_csv_headers

  def analyze
    csv_data = csv_file.read
    csv_file.rewind
    @analyzer = AttendanceAnalyzerService.new(csv_data)
    @analyzer.analyze
  end

  def row_errors
    @analyzer&.errors || []
  end

  def monthly_summary
    return {} unless @analyzer
    @analyzer.monthly_summary
  end

  private

  def valid_csv_format
    return if csv_file&.content_type.in?(["text/csv", "application/vnd.ms-excel"])
    errors.add(:csv_file, 'はCSVファイル（.csv）である必要があります')
  end

  def valid_csv_headers
    return if csv_file.blank?

    begin
      csv_data = csv_file.read
      csv_file.rewind
      utf8_data = csv_data.force_encoding('Shift_JIS').encode('UTF-8', invalid: :replace, undef: :replace)
      headers = CSV.parse(utf8_data, headers: true).headers.map(&:to_s)

      missing = REQUIRED_HEADERS - headers
      if missing.any?
        errors.add(:csv_file, "に必要なヘッダーがありません: #{missing.join(', ')}")
      end
    rescue => e
      errors.add(:csv_file, "の読み込みに失敗しました（#{e.message}）")
    end
  end
end
