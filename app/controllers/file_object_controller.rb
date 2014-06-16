class FileObjectController < ApplicationController
  before_action :no_login_goto_root

  def index
    @directory_id = params[:id]

    @file_objects       = FileObject.where(parent_directory_id: @directory_id).order(:object_mode, :name)
    @parent_directories = FileObject.get_parent_directories(@directory_id)
  end

  def files_upload
    parent_directory_id = params[:parent_directory_id]

    params[:upload_files].each do |upload_file|
      file_object = FileObject.new
      file_object.file_save(upload_file, parent_directory_id)
    end

    redirect_to directory_path(parent_directory_id)
  end

  def create_directory
    @file_object = FileObject.new(new_directory_params)
    @file_object.save
  end

  def new_directory_form
    render layout: false
  end

  def download
    file_object = FileObject.find_by(id: params[:id])
    send_file file_object.file_fullpath, filename: file_object.name
  end

  def destroy
    file_objects = FileObject.where(id: params[:file_object_checkeds])

    file_objects.each do |file_object|
      file_object.go_to_bed
    end

    render layout: false
  end

  private

  def no_login_goto_root
    redirect_to(login_path) if !signed_in?
  end

  private

  def new_directory_params
    params.require(:file_object).permit(:name, :parent_directory_id, :object_mode)
  end
end
