$(document).ready(function(){
    window.addEventListener('message', function(event) {
        var data = event.data;

		if (data.type == "playAudio") {

			playAudio(data.audioFileName, data.volume)

		}else if (data.type == "telegrams") {

			// console.log('hastelegrams: '+data.hasTelegrams)
			if (data.hasTelegrams == true){
				$('#telegram-container').removeClass('display-none');
				$('#telegram-container').addClass('display');
			} else {
				$('#telegram-container').removeClass('display');
				$('#telegram-container').addClass('display-none');
			}

		}else if (data.type == "debugTool") {

			// Remove old debug posts
			$("#debug-container").children().not(":first").remove();

			// Put the sent info on the screen
			var pairs = JSON.parse(data.pairs);
			for (const key in pairs) {
				var $newItem = $("#debug-item-template").clone();
				$newItem.attr("id", ""); 
				$newItem.appendTo("#debug-container");
				$newItem.find(".debug-item-key").eq(0).text(key);
				$newItem.find(".debug-item-value").eq(0).text(pairs[key]);
			}

		}
    });
	function playAudio(audioFileName, volume) {
		var audio = new Audio('assets/audio/'+audioFileName);
		audio.volume = volume;
  		audio.play();
	};
});