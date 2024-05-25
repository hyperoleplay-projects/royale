var $progressBar = null;
var $progressBarPercent = 0;

$(document).ready(function() {
    $("#hud").fadeIn();

    window.addEventListener("message", function(event) {
        let data = event.data;

        switch (data.action) {
            case "createProgressBar":
                createProgressBar(data["time"],data["text"]);

                break;
            case "removeProgressBar":
                removeCurrentProgressBar();

                break;
            default:
                break;
        }
    });
});

function createProgressBar($time,$text) {
    if ($progressBar !== null) {
        removeCurrentProgressBar();
    }

    $progressBarPercent = 0;

    let $interval = ($time/100 * 1000)

    $("#progress-bar").html(`
        <div class="info">
            <div class="percent" id="progress-percent">${$progressBarPercent}%</div>
            <div class="text">${$text.toUpperCase()}</div>
        </div>
        <div class="bar"><div id="progress-bar-bar" style="width: 0px" class="fill"></div></div>
    `);

    $progressBar = setInterval(() => {
        if ($progressBarPercent < 100) {
            $progressBarPercent = $progressBarPercent + 1;
            $("#progress-percent").html($progressBarPercent+"%");
            $("#progress-bar-bar").css("width",$progressBarPercent+"%");
        } else {
            setTimeout(() => {
                removeCurrentProgressBar();
            }, 1000);
            return;
        }
    }, $interval);
}

function removeCurrentProgressBar() {
    if ($progressBar !== null) {
        clearInterval($progressBar);
        $progressBar = null;
        $progressBarPercent = 0;
    }
    $("#progress-bar").empty();
}
