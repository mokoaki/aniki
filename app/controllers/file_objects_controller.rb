class FileObjectsController < ApplicationController
  before_action do
    redirect_to(login_path) if !signed_in?
  end

  def index
  end

  def parent_directories_list
    @parent_directories_list = FileObject.get_directory_object_by_id_hash(params[:file_object_id_hash]).get_parent_directories_list

    render :layout => false
  end

  def current_files_list
    directory_object = FileObject.get_directory_object_by_id_hash(params[:file_object_id_hash])
    @current_files_list = FileObject.where(parent_directory_id: directory_object[:id], object_mode: [2, 3, 4])

    render :layout => false
  end

  def proc
    case params[:proc_mode]
    when 'file_upload'
      proc_file_upload
    when 'directory_make'
      proc_directory_make
    when 'object_rename'
      proc_object_rename
    when 'object_paste'
      proc_object_paste
    when 'object_delete'
      proc_object_delete
    end

    render text: ''
  end

  def download
    file_object = FileObject.find_by(id_hash: params[:id_hash])
    send_file file_object.file_fullpath, filename: file_object.name
  end

  private

  def proc_file_upload
    current_directory_id_hash = params[:current_directory_id_hash]
    current_directory_object  = FileObject.get_directory_object_by_id_hash(current_directory_id_hash)
    upload_files              = params[:upload_files]

    upload_files.each do |upload_file|
      current_directory_object.file_upload(upload_file)
    end
  end

  def proc_directory_make
    current_directory_id_hash = params[:current_directory_id_hash]
    current_directory_object  = FileObject.get_directory_object_by_id_hash(current_directory_id_hash)
    new_directory_name        = params[:new_directory_name]

    current_directory_object.directory_make(new_directory_name)
  end

  def proc_object_rename
    rename_object_id_hash = params[:rename_object_id_hash]
    rename_object_name    = params[:rename_object_name]
    file_object           = FileObject.get_file_or_directory_object_by_id_hash(rename_object_id_hash)

    file_object.object_rename(rename_object_name)
  end

  def proc_object_paste
    current_directory_id_hash = params[:current_directory_id_hash]
    paste_object_id_hashes    = params[:checked_object_id_hashes].split(',')
    paste_objects             = FileObject.get_file_or_directory_object_by_id_hashes(paste_object_id_hashes)

    paste_objects.each do |file_object|
      file_object.object_paste(current_directory_id_hash)
    end
  end

  def proc_object_delete
    delete_object_id_hashes = params[:checked_object_id_hashes].split(',')
    delete_objects          = FileObject.get_file_or_directory_object_by_id_hashes(delete_object_id_hashes)

    delete_objects.each do |file_object|
      file_object.object_delete
    end
  end
end
