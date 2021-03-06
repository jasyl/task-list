require "test_helper"

describe TasksController do
  let (:task) {
    Task.create name: "sample task", description: "this is an example for a test",
    completed_at: Time.now + 5.days
  }
  
  # Tests for Wave 1
  describe "index" do
    it "can get the index path" do
      # Act
      get tasks_path
      
      # Assert
      must_respond_with :success
    end
    
    it "can get the root path" do
      # Act
      get root_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  # Unskip these tests for Wave 2
  describe "show" do
    it "can get a valid task" do

      # Act
      get task_path(task.id)
      
      # Assert
      must_respond_with :success
    end
    
    it "will redirect for an invalid task" do

      # Act
      get task_path(-1)
      
      # Assert
      must_respond_with :redirect
    end
  end
  
  describe "new" do
    it "can get the new task page" do
      
      # Act
      get new_task_path
      
      # Assert
      must_respond_with :success
    end
  end
  
  describe "create" do
    it "can create a new task" do

      # Arrange
      task_hash = {
        task: {
          name: "new task",
          description: "new task description",
          completed_at: nil,
        },
      }
      
      # Act-Assert
      expect {
        post tasks_path, params: task_hash
      }.must_change "Task.count", 1
      
      new_task = Task.find_by(name: task_hash[:task][:name])
      expect(new_task.description).must_equal task_hash[:task][:description]
      expect(new_task.completed_at).must_equal task_hash[:task][:completed_at]
      
      must_respond_with :redirect
      must_redirect_to task_path(new_task.id)
    end
  end
  
  # Unskip and complete these tests for Wave 3
  describe "edit" do
    it "can get the edit page for an existing task" do
      get edit_task_path(task.id)

      must_respond_with :success
    end
    
    it "will respond with redirect when attempting to edit a nonexistant task" do
      get edit_task_path(-1)

      # redirect to the homepage
      must_redirect_to root_path
    end
  end
  
  # Uncomment and complete these tests for Wave 3
  describe "update" do
    # Note:  If there was a way to fail to save the changes to a task, that would be a great
    #        thing to test.
    before do
      @task_update = {
        task: {
          name: "updated task",
          description: "updated task description",
          completed_at: Time.now.to_s
        }
      }
    end
    it "can update an existing task" do
      original_task = task
      # check that the number of tasks doesn't change
      expect {
        patch task_path(original_task.id), params: @task_update
      }.wont_change "Task.count"

      # check that updates made it into database
      updated_task = Task.find_by(id: original_task.id)
      expect(updated_task.name).must_equal @task_update[:task][:name]
      expect(updated_task.description).must_equal @task_update[:task][:description]
      expect(updated_task.completed_at).must_equal @task_update[:task][:completed_at]

      # confirm redirection to show page
      must_respond_with :redirect
      must_redirect_to task_path(task.id)

    end
    
    it "will redirect to the root page if given an invalid id" do
      # check that the number of tasks doesn't change
      expect {
        patch task_path(-1), params: @task_update
      }.wont_change "Task.count"

      must_respond_with :redirect
      must_redirect_to root_path
    end
  end
  
  # Complete these tests for Wave 4
  describe "destroy" do
    it "can delete an existing task" do
      original_task = task

      expect {
        delete task_path(task.id)
      }.must_differ "Task.count", -1

      deleted_task = Task.find_by(id: task.id)
      expect(deleted_task).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "will render a 404 page when trying to delete a non-existant task" do
      expect {
        delete task_path(-1)
      }.wont_change "Task.count"

      must_respond_with :not_found
    end
  end
  
  # Complete for Wave 4
  describe "toggle_complete" do
    before do
      @task = Task.create name: "sample task", description: "this is an example for a test"
    end

    it "sucessfully marks task completed" do
      expect {
        patch toggle_complete_path(@task.id)
      }.wont_change "Task.count"

      completed_task = Task.find_by(id: @task.id)
      expect(completed_task.completed_at).wont_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "succesfully unmarks task from completed" do
      patch toggle_complete_path(@task.id)
      # unmark complete
      expect {
        patch toggle_complete_path(@task.id)
      }.wont_change "Task.count"

      incomplete_task = Task.find_by(id: @task.id)
      expect(incomplete_task.completed_at).must_be_nil

      must_respond_with :redirect
      must_redirect_to root_path
    end

    it "responds with not_found if task doesn't exist" do
      patch toggle_complete_path(-1)
      must_respond_with :not_found
    end
  end

end
