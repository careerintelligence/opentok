OpenTok 2.0 Archiving Ruby Sample App
=====================

A sample showing how to use the OpenTok 2.0 Archiving API, written in Ruby.

## Prerequisites

1. Ruby 1.8.3 or higher. (Tested against 2.0.0p247).
2. Install `bundler`

  ```bash
  $ sudo gem install bundler
  ```

3. An OpenTok API key, secret and session (from [dashboard.tokbox.com][dashboard]).

## To run this app for yourself

1. Clone this repo.
2. Install dependencies

  ```bash
  $ sudo bundle install
  ```

3. Set the API key & secret environment variables:
  * `API_KEY` -- Your OpenTok API key
  * `API_SECRET` -- Your OpenTok secret

  ```bash
  $ export API_KEY=....
  $ export API_SECRET=...
  ```

4. Run the app:

  ```bash
  $ruby app.rb
  ```

## Then time to test!

1. Open http://localhost:4567/ in Chrome or Firefox 22+

2. Click the "Host view" button. The Host View page publishes an audio-video stream to an
   OpenTok session. It also includes controls that cause the web server to start and stop archiving.

3. Click the Allow button to grant access to the camera and microphone.

4. Click the "Start archiving" button. The session starts recording to an archive. Note that the
   red archiving indicator is displayed in the video view.

5. Open http://localhost:4567/ in a new browser tab. (You may want to mute your computer speaker
   to prevent feedback. You are about to publish two audio-video streams from the same computer.)

6. Click the "Participant view" button. The page connects to the OpenTok session, displays
   the existing stream (from the Host View page).

7. Click the Allow button in the page to grant access to the camera and microphone. The page
   publishes a new stream to the session. Both streams are now being recorded to an archive.

8. On the Host View page, click the "Stop archiving" button.

9. Click the "past archives" link in the page. This page lists the archives that have been recorded.
   Note that it may take up to 2 minutes for the video file to become available (for a 90-minute 
   recording).

10. Click a listing for an available archive to download the MP4 file of the recording.

## Understanding the code

This sample app shows how to use the archiving API in the OpenTok 2.0 Ruby SDK.

### Starting an archive

The host_view.erb file (in the views directory) includes a button for starting the archive:

    <button class="btn btn-danger start">Start archiving</button>

When the user clicks this button, the page makes an Ajax call back to the server:

    $(".start").click(function(event){
      $.get("start-archive");
    })

The app.rb file processes the page request and calls the archives.create() method of the OpenTokSDK
object:

    get "/start-archive" do
      content_type :json
      begin
        opentok.archives.create(sessionId, :name => "Ruby Archiving Sample App").to_json
      rescue => e
        { :error => e }.to_json
      end
    end

The archives.create() method starts recording an archive, and it takes two parameters:

* The session ID of the OpenTok session to archive
* A name (to help identify the archive)

You can only start recording an archive in a session that has active clients connected.

In the page on the web client, the Session object (in JavaScript) dispatches an archiveStarted
event. The page stores the archive ID (a unique identifier of the archive) in an archiveID variable:

    session.on('archiveStarted', function(event) {
      archiveID = event.id;
      console.log("ARCHIVE STARTED");
      $(".start").hide();
      $(".stop").show();
    });

### Stopping an archive

The app.rb file processes the page request and calls the stop_archive() method of the OpenTokSDK
object:

    get "/stop-archive/:archive_id" do
      content_type :json
      opentok.archives.find(params[:archive_id]).stop.to_json
    end

The archives.find() method returns an Archive object (based on an archive ID). And the stop() method
of the Archive object stops an archive, based on the archive ID.

In the page on the web client, the Session object (in JavaScript) dispatches an archiveStopped
event. The page stores the archive ID (a unique identifier of the archive) in an archiveID variable:

    session.on('archiveStopped', function(event) {
      archiveID = null;
      console.log("ARCHIVE STOPPED");
      $(".start").show();
      $(".stop").hide();
    });

### Listing archives

The app.rb file processes the request for the past_archives.html page. It includes the following
code:

    past = opentok.archives.all :offset => offset, :limit => 5

This code calls the archives.all method of the OpenTokSDK object. This method returns
an ArchiveList object, which represents a list of archives created for the API key. The method
takes two parameters:

* offset -- This defines the offset that starts the list.
* count -- This defines how many archives are listed.

Each Archive represents an OpenTok archive, and it includes properties of the archive, including:

* id -- The archive ID, which uniquely defines the archive.
* name -- The archive name.
* created_A_at -- The timestamp for when the archive was created.
* duration -- The duration of the archive (in seconds).
* status -- The status of the archive. This can be one of the following:
  * "available" -- The archive is available for download from the OpenTok cloud.
  * "failed" -- The archive recording failed.
  * "started" -- The archive started and is in the process of being recorded.
  * "stopped" -- The archive stopped recording.
  * "uploaded" -- The archive is available for download from an S3 bucket you specified (see
    [Setting an archive upload target](../../../REST-API.md#set_upload_target)).
* url -- The URL of the download file for the recorded archive (if available) 

The Ruby code in the past_archives.erb page then iterates through the list of Archive objects
and displays UI based on the id, name, created_at, duration, status, and url properties of the OpenTokArchive object:

    <table class="table">
      <thead>
        <tr>
          <th>&nbsp;</th>
          <th>Created</th>
          <th>Duration</th>
          <th>Status</th>
        </tr>
      </thead>
      <tbody>
        <% archives.each do |item| %>

        <tr data-item-id="<%= item.id %>">
          <td>
            <% if item.status == 'available' && item.url && item.url.length > 0 %>
            <a href="/download-archive?id=<%= item.id %>">
            <% end %>
            <%= item.name || "Untitled" %>
            <% if item.status == 'available' && item.url && item.url.length > 0 %>
            </a>
            <% end %>
          </td>
          <td><%= item.created_at.strftime("%b %d, %Y %l:%M %p") %></td>
          <td><%= item.duration %> seconds</td>
          <td><%= item.status %></td>
          <td>
            <% if item.status == 'available' %>
              <a href="/delete-archive/<%= item.id %>">Delete</a>
            <% else %>
              &nbsp;
            <% end %>
          </td>
        </tr>

        <% end %>
      </tbody>
    </table>
    

### Downloading archives

The url property of an Archive object is the download URL for the available archive.
See the previous section, which shows how this URL is added to the past_archives.html page as
a download link.

### Deleting an archive

The past_archives.html page includes a Ajax call to a page that deletes an archive (based on the
user clicking a link):

     <a href="/delete-archive/<%= item.id %>">Delete</a>

The app.rb file processes the page request and calls the delete_archive() method of the OpenTokSDK
object, passing in the archive ID of the archive to be deleted:

    get "/delete-archive/:archive_id" do
      opentok.archives.find(params[:archive_id]).delete
      redirect "/past-archives"
    end


## Documentation

* [OpenTok Ruby SDK documentation](../../README.md)
* [Archiving JavaScript API documentation](../../../JavaScript-API.md)
* [How to deploy the sample app on Heroku](docs/Heroku.md)


## More information

See the list of known issues in the main [README file](../../../README.md).

The OpenTok 2.0 archiving feature is currently in beta testing.

If you have questions or to provide feedback, please write <denis@tokbox.com>.

[dashboard]: https://dashboard.tokbox.com/
