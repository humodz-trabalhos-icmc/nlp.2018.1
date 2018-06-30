$(document).ready(onReady);


function onReady() {
    $('.btn-search').click(searchAction);

    $('.txt-medicine').keyup(function(e) {
        if(e.keyCode === 13) {
            searchAction();
        }
    });
}


function searchAction() {
    var queryParams = {query: $('.txt-medicine').val()};
    if(queryParams.query.length === 0) {
        return alert('Digite alguma coisa no campo de busca!');
    }

    $.ajax({
        url: '/search',
        data: queryParams,
        success: onAjaxResponse
    });
}


function onAjaxResponse(result) {
    console.log(result);
    $('.answer').removeClass('hidden');
    $('.medicine-name').text(result.drug_name);
    $('.medicine-function').text(result.document);
}
