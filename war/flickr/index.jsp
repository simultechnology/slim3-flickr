<%@page pageEncoding="UTF-8" isELIgnored="false" session="false"%>
<html>
    <head>
        <meta charset=UTF-8">
        <title>Frickr Music Slide</title>
        <link href="/css/style.css" media="screen" rel="stylesheet" type="text/css">
    </head>
    <body>
        <h1 class="title">Frickr Music Slide</h1>
        <div>
            <table id="contact_table" border="0" cellspacing="0" width="1120">
                <tbody>
                    <tr>
                        <td class="formLeft" colspan="2">
                            &nbsp;&nbsp;&nbsp;username&nbsp;:&nbsp; <input class="inputStyle" id="user_name" name="user_name" type="text" value="simultechnology">
                        </td>
                        <td class="formCenter" colspan="2">
                            photoset&nbsp;:&nbsp;<span id="photo_set"></span>
                        </td>
                        <td class="formRight" colspan="2">
                            youtube video id&nbsp;:&nbsp; 
							<input class="inputStyle" id="youtube_id" name="youtube_id" type="text">
							<input type="button" value="play" id="youtube_play_button">
							<input type="button" value="stop" id="youtube_stop_button">
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div id="error_msg">
        </div>
        <table border="0" width="1120" cellspacing="0" cellpadding="0" bgcolor="#000000" id="slide_table">
            <tr>
                <td width="550" valign="top">
                    <div id="fadeshow1">
                    </div>
                </td>
                <td width="0" valign="top">
                    &nbsp;
                </td>
                <td width="550" valign="top" textalign="center">
                    <div id="fadeshow3">
                </td>
            </tr>
        </table>
        <div id="videoDiv">
        </div>
        <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.min.js">
        </script>
        <script type="text/javascript" src="/js/fadeslideshow.js">
        </script>
        <script src="http://www.google.com/jsapi" type="text/javascript">
        </script>
        <script type="text/javascript">
            
            google.load("swfobject", "2.1");
            
            baseUrl = 'http://api.flickr.com/services/rest?jsoncallback=?';
            apiKey = '99f59efe4fcb3fdee471c25de0d7a289';
            format = 'json';
            userName = "";
            nsid = "";
            (function($){
                $(document).ready(function(){
                    // エラーメッセージの削除
                    $("#error_msg").children().remove();
                    $('#user_name').focus();
                    searchPhoto();
                    $('#youtube_play_button').click(function(){
                        youtube_id = $('#youtube_id').val();
                        runYoutube(youtube_id);
                    });
                    $('#youtube_stop_button').click(function(){
                        stopYoutube();
                    });
                    
                    $('#user_name').blur(function(){
                        searchPhoto();
                    });
                });
            })(jQuery);
            
            
            function searchPhoto(){
                (function($){
                    $("#error_msg").children().remove();
                    //　フォームから取得するユーザ名
                    userName = $('#user_name').val();
                    // ユーザ名が入力されている場合
                    if (userName.length) {
                    
                        var useridParams = {
                            format: format,
                            method: 'flickr.people.findByUsername',
                            api_key: apiKey,
                            username: userName
                        };
                        $.getJSON(baseUrl, useridParams, function(json){
                            if (json.stat == 'ok') {
                                // ユーザIDの取得
                                nsid = json.user.nsid;
                                var photosetParams = {
                                    format: format,
                                    method: 'flickr.photosets.getList',
                                    api_key: apiKey,
                                    user_id: nsid
                                };
                                $.getJSON(baseUrl, photosetParams, function(json){
                                    if (json.stat == 'ok') {
                                        // セットの取得
                                        photosetArray = json.photosets.photoset;
                                        if (photosetArray.length) {
                                            var selectForm = "";
                                            selectForm = "<select name='photoset' id='select_photoset' onChange='selectPhotoSet()' >";
                                            selectForm += "<option value=''></option>";
                                            for (var obj in photosetArray) {
                                                selectForm += ("<option value='" + photosetArray[obj].id + "'> " +
                                                photosetArray[obj].title._content +
                                                "</option>");
                                            }
                                            selectForm += "</select>";
                                            $("#photo_set").children().remove();
                                            $(selectForm).appendTo("#photo_set");
                                        }
                                        else {
                                            $("#photo_set").children().remove();
                                        }
                                    }
                                    else {
                                        $("#photo_set").children().remove();
                                    }
                                });
                                
                                var photoSearchParams = {
                                    format: format,
                                    method: 'flickr.photos.search',
                                    api_key: apiKey,
                                    per_page: '200',
                                    user_id: nsid
                                };
                                $.getJSON(baseUrl, photoSearchParams, function(json){
                                    if (json.stat == 'ok') {
                                        imagearray = [];
                                        photos = json.photos.photo;
                                        loopPhotos(photos);
                                    }
                                    else {
                                        $("#fadeshow1").children().remove();
                                        $("#fadeshow3").children().remove();
                                        $("#photo_set").children().remove();
                                    }
                                });
                            }
                            else {
                                $("#fadeshow1").children().remove();
                                $("#fadeshow3").children().remove();
                                $("#photo_set").children().remove();
                                $("#error_msg").append("<p>There's no photo.<p>");
                            }
                        });
                    }
                })(jQuery);
            }
            
            function selectPhotoSet(){
                (function($){
                    imagearray = [];
                    var photosetParams = {
                        format: format,
                        method: 'flickr.photosets.getPhotos',
                        api_key: apiKey,
                        photoset_id: $('#select_photoset').val()
                    };
                    $.getJSON(baseUrl, photosetParams, function(json){
                    
                        if (json.stat == 'ok') {
                            // 
                            photos = json.photoset.photo;
                            loopPhotos(photos);
                        }
                        else {
                            $("#fadeshow1").children().remove();
                            $("#fadeshow3").children().remove();
                            $("#photo_set").children().remove();
                        }
                    });
                })(jQuery);
            }
            
            function loopPhotos(photos){
                (function($){
                    if (photos.length) {
                        imagearray = [];
                        for (var photo in photos) {
                            imageUrl = "http://farm6.static.flickr.com/" + photos[photo].server + "/" + photos[photo].id + "_" + photos[photo].secret + ".jpg";
                            var url_array = [imageUrl, "", "", ""];
                            imagearray.push(url_array);
                        }
                        hoge(imagearray);
                    }
                    else {
                        $("#fadeshow1").children().remove();
                        $("#fadeshow3").children().remove();
                        $("#photo_set").children().remove();
                        $("#error_msg").append("<p>There's no photo.<p>");
                    }
                })(jQuery);
            }
        </script>
        <script type="text/javascript">
                                                
            function hoge(imagearray) {
				
				mygallery = new fadeSlideShow({
                    wrapperid: "fadeshow1", 
                    dimensions: [550, 550], 
                    imagearray: imagearray,
                    displaymode: {
                        type: 'auto',
                        pause: 2500,
                        cycles: 0,
                        wraparound: false
                    },
                    persist: false, 
                    fadeduration: 1000, 
                    descreveal: "ondemand",
                    togglerid: ""
                })
                
                mygallery3 = new fadeSlideShow({
                    wrapperid: "fadeshow3", 
                    dimensions: [550, 550], 
                    imagearray: imagearray.reverse(),
                    displaymode: {
                        type: 'auto',
                        pause: 2000,
                        cycles: 0,
                        wraparound: false
                    },
                    persist: false,
                    fadeduration: 1000,
                    descreveal: "peekaboo",
                    togglerid: ""
                })
            }

            function runYoutube(youtube_id) {
                
                // The video to load.
                var videoID = youtube_id;
                // Lets Flash from another domain call JavaScript
                var params = { allowScriptAccess: "always" };
                // The element id of the Flash embed
                var atts = { id: "ytplayer" };
                // All of the magic handled by SWFObject (http://code.google.com/p/swfobject/)
                swfobject.embedSWF("http://www.youtube.com/v/" + videoID + "&enablejsapi=1&playerapiid=ytplayer", 
                                   "videoDiv", "0", "0", "8", null, null, params, atts);
		        
				player = document.getElementById("ytplayer");
				if (player.loadVideoById) {
                    player.loadVideoById(videoID);
				}

        
        }
            function onYouTubePlayerReady(playerId) {
              player = document.getElementById("ytplayer");
              player.playVideo();
            }
			
			function stopYoutube() {
                player = document.getElementById("ytplayer");
                player.stopVideo();
			}
        </script>
    </body>
</html>
