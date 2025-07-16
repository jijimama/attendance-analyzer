class AttendancesController < ApplicationController
  def new
    @form = AttendanceUploadForm.new
  end

  def create
    @form = AttendanceUploadForm.new(csv_file: params[:csv_file])

    if @form.valid?
      @results = @form.analyze
      render :new
    else
      render :new, status: :unprocessable_entity
    end
  end
end
