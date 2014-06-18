class FileObjectsController < ApplicationController
  before_action :no_login_goto_root

  def index
    @current_directory_id = params[:id]

    @file_objects       = FileObject.where(parent_directory_id: @current_directory_id).order(:object_mode, :name)
    @parent_directories = FileObject.get_parent_directories(@current_directory_id)
  end

  def upload
    parent_directory_id = params[:parent_directory_id]

    params[:upload_files].each do |upload_file|
      file_object = FileObject.new
      file_object.file_save(upload_file, parent_directory_id)
    end

    redirect_to directory_path(parent_directory_id)
  end

  def create
    file_object                     = FileObject.new
    file_object.name                = params[:name]
    file_object.parent_directory_id = params[:parent_directory_id]
    file_object.object_mode         = 2
    file_object.save

    render file_object
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

    render nothing: true
  end

  def cut
    session[:file_object_checkeds] = params[:file_object_checkeds].uniq
    render nothing: true
  end

  def paste
    directory_id = params[:directory_id].to_i
    file_objects = FileObject.where(id: session[:file_object_checkeds])

    @result_file_objects = []

    file_objects.each do |file_object|
      if file_object.parent_directory_id != directory_id
        file_object.parent_directory_id = directory_id
        file_object.save

        @result_file_objects << file_object
      end
    end

    session[:file_object_checkeds] = nil

    render @result_file_objects
  end

  private

  def no_login_goto_root
    redirect_to(login_path) if !signed_in?
  end
end
