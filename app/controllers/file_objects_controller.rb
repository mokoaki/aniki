class FileObjectsController < ApplicationController
  before_action do
    redirect_to(login_path) if !signed_in?
  end

  def index
    file_objects = FileObject.get_children_by_id_hash(params[:id_hash]).select(:name, :parent_directory_id_hash, :object_mode, :id_hash, :size, :created_at)
    render json: file_objects
  end

  def create
    if params[:file]
      file_object = FileObject.upload_file(params)
    else
      file_object = FileObject.create_directory(params)
    end

    # #idを返さないようにする
    file_object[:id] = 0

    render json: file_object, status: file_object.errors.messages.empty? ? 200 : 500
  end

  def update
    file_object = FileObject.get_file_or_directory_object_by_id_hash(params[:id])

    if !file_object.is_root? && !file_object.is_trash?
      file_object[:parent_directory_id_hash] = params[:parent_directory_id_hash]
      file_object[:name] = params[:name]
      file_object.save
    end

    render json: file_object, status: file_object.errors.messages.empty? ? 200 : 500
  end

  def destroy
    delete_object = FileObject.get_file_or_directory_object_by_id_hash(params[:id_hash]).object_delete
    render json: delete_object, status: delete_object.errors.messages.empty? ? 200 : 500
  end

  def parent_directories_list
    parent_directories_list = FileObject.get_directory_object_by_id_hash(params[:id_hash]).get_parent_directories_list
    render json: parent_directories_list
  end

  def file_download
    file_object = FileObject.get_file_object_by_id_hash(params[:id_hash])
    send_file file_object.file_fullpath, filename: file_object.name
  end
end
