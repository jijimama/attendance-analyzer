class AttendancesController < ApplicationController
  def new
    @form = AttendanceUploadForm.new
  end

  def create
    @form = AttendanceUploadForm.new(csv_file: params[:csv_file])

    if @form.valid?
      @results = @form.analyze
      @monthly_summary = @form.monthly_summary
      @monthly_average = @form.monthly_average
      @monthly_attendance_days = @form.monthly_attendance_days
      @monthly_overtime_hours = @form.monthly_overtime_hours
      render :new
    else
      render :new, status: :unprocessable_entity
    end
  end
end
