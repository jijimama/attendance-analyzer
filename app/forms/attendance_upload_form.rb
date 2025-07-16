# app/forms/attendance_upload_form.rb
class AttendanceUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  
  attr_accessor :csv_file
  
  validates :csv_file, presence: true
  validate :csv_format
  
  def analyze
    csv_data = csv_file.read
    AttendanceAnalyzerService.new(csv_data).analyze
  end
  
  private
  
  def csv_format
    return if csv_file&.content_type == 'text/csv'

    errors.add(:csv_file, 'はCSVファイルである必要があります')
  end
end
  