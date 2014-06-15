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

  def directory_create
    @file_object = FileObject.new
    @file_object.directory_save(params)

    render :partial => 'file_object_line', :locals => { :file_object => @file_object }
  end

  def new_directory_form
    render :layout => false
  end

  private

  def no_login_goto_root
    redirect_to(login_path) if !signed_in?
  end
end
