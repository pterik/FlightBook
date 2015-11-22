function pilsetano(pilseta1){
	selectOrig(pilseta1);
}
function pilsetauz(pilseta2){
	selectDest(pilseta2);
}
function redir(s){
	var d = s.options[s.selectedIndex].value;
	window.self.location.href = d;
	s.selectedIndex = 0;
}

var ImgArr = new Array();
ImgArr[0] = new Image();
ImgArr[0].src = "/templates/img/en/hotel_bann_01a.png"
ImgArr[1] = new Image();
ImgArr[1].src = "/templates/img/en/hotel_bann_01.png"
ImgArr[2] = new Image();
ImgArr[2].src = "/templates/img/en/car_bann_01a.png"
ImgArr[3] = new Image();
ImgArr[3].src = "/templates/img/en/car_bann_01.png"
ImgArr[4] = new Image();
ImgArr[4].src = "/templates/img/en/express_bann_01a.png"
ImgArr[5] = new Image();
ImgArr[5].src = "/templates/img/en/express_bann_01.png"
ImgArr[6] = new Image();
ImgArr[6].src = "/templates/img/en/taxia.png"
ImgArr[7] = new Image();
ImgArr[7].src = "/templates/img/en/taxi.png"
ImgArr[8] = new Image();
ImgArr[8].src = "/templates/img/en/travins_bann_01a.png"
ImgArr[9] = new Image();
ImgArr[9].src = "/templates/img/en/travins_bann_01.png"
ImgArr[10] = new Image();
ImgArr[10].src = "/templates/img/en/meal_bann_01a.png"
ImgArr[11] = new Image();
ImgArr[11].src = "/templates/img/en/meal_bann_01.png"
ImgArr[12] = new Image();
ImgArr[12].src = "/templates/img/en/voucher_bann_01a.png"
ImgArr[13] = new Image();
ImgArr[13].src = "/templates/img/en/voucher_bann_01.png"
ImgArr[14] = new Image();
ImgArr[14].src = "/templates/img/en/shop_bann_01a.png"
ImgArr[15] = new Image();
ImgArr[15].src = "/templates/img/en/shop_bann_01.png"

function changeImage(Obj, num){
 Obj.src = ImgArr[num].src;
}

function popup(url,id,query){
  var l_width  = 620;
  var l_height = 380;
  window.open(url, 'popup', 'width='+l_width+',height='+l_height+',resizable=no,scrollbars=yes');
}


var BMImgArr = new Array();
BMImgArr[0] = new Image();
BMImgArr[0].src = "/templates/img/en/bm/menu/sidebar_mouseover_0000_1.png"
BMImgArr[1] = new Image();
BMImgArr[1].src = "/templates/img/en/bm/menu/sidebar_std_0000_1.png"
BMImgArr[2] = new Image();
BMImgArr[2].src = "/templates/img/en/bm/menu/sidebar_mouseover_0001_2.png"
BMImgArr[3] = new Image();
BMImgArr[3].src = "/templates/img/en/bm/menu/sidebar_std_0001_2.png"
BMImgArr[4] = new Image();
BMImgArr[4].src = "/templates/img/en/bm/menu/sidebar_mouseover_0002_3.png"
BMImgArr[5] = new Image();
BMImgArr[5].src = "/templates/img/en/bm/menu/sidebar_std_0002_3.png"
BMImgArr[6] = new Image();
BMImgArr[6].src = "/templates/img/en/bm/menu/sidebar_mouseover_0003_4.png"
BMImgArr[7] = new Image();
BMImgArr[7].src = "/templates/img/en/bm/menu/sidebar_std_0003_4.png"
BMImgArr[8] = new Image();
BMImgArr[8].src = "/templates/img/en/bm/menu/sidebar_mouseover_0004_5.png"
BMImgArr[9] = new Image();
BMImgArr[9].src = "/templates/img/en/bm/menu/sidebar_std_0004_5.png"
BMImgArr[10] = new Image();
BMImgArr[10].src = "/templates/img/en/bm/menu/sidebar_mouseover_0005_6.png"
BMImgArr[11] = new Image();
BMImgArr[11].src = "/templates/img/en/bm/menu/sidebar_std_0005_6.png"
BMImgArr[12] = new Image();
BMImgArr[12].src = "/templates/img/en/bm/menu/sidebar_mouseover_0006_7.png"
BMImgArr[13] = new Image();
BMImgArr[13].src = "/templates/img/en/bm/menu/sidebar_std_0006_7.png"
BMImgArr[14] = new Image();
BMImgArr[14].src = "/templates/img/en/bm/menu/sidebar_mouseover_0007_8.png"
BMImgArr[15] = new Image();
BMImgArr[15].src = "/templates/img/en/bm/menu/sidebar_std_0007_8.png"
BMImgArr[16] = new Image();
BMImgArr[16].src = "/templates/img/en/bm/menu/sidebar_mouseover_0008_9.png"
BMImgArr[17] = new Image();
BMImgArr[17].src = "/templates/img/en/bm/menu/sidebar_std_0008_9.png"
BMImgArr[18] = new Image();
BMImgArr[18].src = "/templates/img/en/bm/menu/sidebar_mouseover_0009_10.png"
BMImgArr[19] = new Image();
BMImgArr[19].src = "/templates/img/en/bm/menu/sidebar_std_0009_10.png"
BMImgArr[20] = new Image();
BMImgArr[20].src = "/templates/img/en/bm/menu/sidebar_mouseover_0010_11.png"
BMImgArr[21] = new Image();
BMImgArr[21].src = "/templates/img/en/bm/menu/sidebar_std_0010_11.png"

function changeBMImage(Obj, num){
 Obj.src = BMImgArr[num].src;
}


