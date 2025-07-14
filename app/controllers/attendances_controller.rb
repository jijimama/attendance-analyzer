class AttendancesController < ApplicationController
  def new; end

  def create
    if params[:csv_file].present?
      csv_data = params[:csv_file].read
      analyzer = AttendanceAnalyzerService.new(csv_data)
      @results = analyzer.analyze
      render new_attendance_path, notice: 'CSVファイルの解析が完了しました'
    else
      redirect_to root_path, notice: 'CSVファイルが必要です'
    end
  end
end
