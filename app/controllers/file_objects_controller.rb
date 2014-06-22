class FileObjectsController < ApplicationController
  before_action do
    redirect_to(login_path) if !signed_in?
  end

  def index
    @current_directory_id        = params[:id]
    @current_directory_id_digest = FileObject.get_digest(@current_directory_id)
    @file_objects                = FileObject.where(parent_directory_id: @current_directory_id)
    @parent_directories_list     = FileObject.find_by(id: @current_directory_id).get_parent_directories_list
  end

  def upload
    current_directory_id = FileObject.check_digest(params[:current_directory_id], params[:current_directory_id_digest])

    if current_directory_id
      current_file_object = FileObject.get_directory_by_id(current_directory_id)

      params[:upload_files].each do |upload_file|
        file_object = current_file_object.children.new
        file_object.file_save(upload_file)
      end
    end

    redirect_to :back
  end

  def create
    current_directory_id = FileObject.check_digest(params[:current_directory_id], params[:current_directory_id_digest])

    if current_directory_id
      current_file_object = FileObject.get_directory_by_id(current_directory_id)

      file_object             = current_file_object.children.new
      file_object.name        = params[:name]
      file_object.object_mode = 3
      file_object.save

      render file_object
    else
      render nothing: true
    end
  end

  def download
    file_object = FileObject.find_by(id: params[:id])
    send_file file_object.file_fullpath, filename: file_object.name
  end

  def destroy
    file_object_ids = FileObject.check_digests(params[:file_object_checkeds])

    if file_object_ids
      file_objects = FileObject.where(id: file_object_ids)

      file_objects.each do |file_object|
        file_object.go_to_bed
      end
    end

    render nothing: true
  end

  def cut
    session[:file_object_checkeds] = FileObject.check_digests(params[:file_object_checkeds])
    render nothing: true
  end

  def paste
    current_directory_id = FileObject.check_digest(params[:current_directory_id], params[:current_directory_id_digest])

    @result_file_objects = []

    if current_directory_id
      current_file_object = FileObject.get_directory_by_id(current_directory_id)
      file_objects = FileObject.where(id: session[:file_object_checkeds])

      file_objects.each do |file_object|
        if file_object.parent_directory_id != current_file_object.id
          file_object.parent_directory_id = current_file_object.id
          file_object.save

          @result_file_objects << file_object
        end
      end
    end

    session[:file_object_checkeds] = nil

    render @result_file_objects
  end

  def rename
    file_object_id = FileObject.check_digest(params[:file_object_id], params[:file_object_id_digest])

    if file_object_id
      file_object = FileObject.find_by(id: file_object_id)
      file_object.name = params[:file_object_name]
      file_object.save
    end

    render nothing: true
  end
end
