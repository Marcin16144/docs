# Insert 20 new plant entries into laka.html
# Inserts from BOTTOM to TOP so earlier line numbers stay valid
$file = "D:\docs\house\rosliny\laka.html"
$utf8noBOM = New-Object System.Text.UTF8Encoding $false
$lines = [IO.File]::ReadAllLines($file, [System.Text.Encoding]::UTF8)

function InsertAt($arr, $idx, $block) {
    $blockLines = @($block -split "`n")
    return $arr[0..($idx-1)] + $blockLines + $arr[$idx..($arr.Length-1)]
}

# ===== TOKSYCZNE — Konwalia majowa (insert before line 801 = index 800) =====
$blk_toks = @'
        <div class="plant-entry" style="border-color:rgba(248,113,113,.4)">
            <div class="pe-photo"><img src="media/laka-konwalia.jpg" alt="Konwalia" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Konwalia majowa</div><div class="pe-latin">Convallaria majalis · rodzina szparagowate</div></div>
                    <div class="pe-badges"><span class="badge badge-toxic">silnie trujaca</span><span class="badge badge-rare">chroniona</span></div>
                </div>
                <div class="pe-desc">Jeden z najbardziej rozpoznawalnych i niebezpiecznych kwiatow polskich lasow i ogrodow. Biale dzwonkowate kwiatki o intensywnym zapachu. CALA ROSLINA jest silnie trujaca — zawiera glikozydy nasercowe (konwalatozyd). Dawniej uzywana w kardiologii, dzis tylko w farmacji.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> V–VI</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Lasy lisciaste, parki, ogrody</div><div class="pe-meta-item"><strong>Trujace:</strong> Cala roslina, nawet woda z wazonu</div></div>
                <div class="pe-warn">SILNA TRUCIZNA — powoduje zaburzenia rytmu serca, wymioty, drgawki. Szczegolnie niebezpieczna dla dzieci i zwierzat domowych. Nie pomylic z czosnkiem niedzwiedzim przed kwitnieniem!</div>
            </div>
        </div>
'@

# ===== JESIEN — Nawloc kanadyjska (insert before line 673 = index 672) =====
$blk_jesien = @'
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-nawloc-k.jpg" alt="Nawloc kanadyjska" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Nawloc kanadyjska (inwazyjna)</div><div class="pe-latin">Solidago canadensis · rodzina astrowate</div></div>
                    <div class="pe-badges"><span class="badge badge-toxic">inwazyjna</span><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Agresywna roslina inwazyjna z Ameryki Polnocnej — opanowuje brzegi rzek, niezagospodarowane tereny i odlogi. Zlote wiechy kwiatowe (VIII–X) o wyzszosci do 2 m. Mimo inwazyjnosci — skuteczna moczopednie, podobnie jak nawloc pospolita. Glownie nalezy ja usuwac i ograniczac rozprzestrzenianie.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VIII–X</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Brzegi rzek, odlogi, niezagospodarowane tereny</div><div class="pe-meta-item"><strong>Status:</strong> Inwazyjna — do zwalczania!</div></div>
                <div class="pe-warn">Inwazyjny gatunek obcy — nie sadzimy, usuwamy! Powoduje zanikanie rodzimej roslinnosci lacowej.</div>
            </div>
        </div>
'@

# ===== LATO — 11 roslin (insert before line 592 = index 591) =====
$blk_lato = @'
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-kozlek.jpg" alt="Kozlek" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Kozlek lekarski (waleriana)</div><div class="pe-latin">Valeriana officinalis · rodzina kozlkowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Roslina mokrych lak i brzegov wod. Rozowawte baldachy kwiatowe o specyficznym zapachu. <strong>Korzen</strong> (wykopywany jesienia lub wiosna) to surowiec farmaceutyczny na bezsennosc, nerwowosc i stres. Zawiera kwas walerianowy i liczne alkaloidy. Jedno z najwazniejszych ziol uspokajajacych w Europie.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–VIII</div><div class="pe-meta-item"><strong>Surowiec:</strong> Korzen (IX–X lub III–IV)</div><div class="pe-meta-item"><strong>Dzialanie:</strong> Uspokajajace, nasenne, spazmolityczne</div></div>
                <div class="pe-warn">Dlugotrwale stosowanie moze powodowac bole glowy. Nie prowadzic pojazdow po wypiciu. Nie laczyc z alkoholem.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-nawloc.jpg" alt="Nawloc" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Nawloc pospolita</div><div class="pe-latin">Solidago virgaurea · rodzina astrowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Zlociste wiechy kwiatowe na skrajach lasow i lak (VII–X). Jedno z najwazniejszych ziol moczopednych — na zapalenie drog moczowych, kamice nerkowa, dne moczanowa. Zawiera saponiny, flawonoidy i taniny. Lagodzi stany zapalne ukladu moczowego.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VII–X</div><div class="pe-meta-item"><strong>Surowiec:</strong> Ziele (kwitnace szczyty)</div><div class="pe-meta-item"><strong>Dzialanie:</strong> Moczopedne, przeciwzapalne, przeciwgrzybicze</div></div>
                <div class="pe-warn">Nie mylic z inwazyjnym gatunkiem nawloc kanadyjska — nawloc pospolita jest nizsza i nie tworzy rozleglych zarrosli.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-malina.jpg" alt="Malina" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Malina wlasciwa</div><div class="pe-latin">Rubus idaeus · rodzina rozowate</div></div>
                    <div class="pe-badges"><span class="badge badge-food">jadalna</span><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Kolczasty krzew skrajow lasow i zrebow. Czerwone owoce (VII–VIII) bogate w witamine C, antocyjany i kwas elagowy. Liscie malinowe to herbata napotna i regulujaca cykl miesiaczkowy. Syrop malinowy — klasyczny srodek napotny na przeziebienia i goraczke. Jedna z najpopularniejszych polskich roslin zielarskich.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Owoce:</strong> VII–VIII</div><div class="pe-meta-item"><strong>Liscie:</strong> V–IX</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Zreby, skraje lasow, zarosla</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-chaber.jpg" alt="Chaber lakowy" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Chaber lakowy</div><div class="pe-latin">Centaurea jacea · rodzina astrowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Rozowo-fioletowe kwiaty dekorujace polskie laki od czerwca do pazdziernika. Bardzo wazna roslina miodna dla pszczol i motyli. W ziololecznictwie stosowany na choroby skory, rany i bol glowy. Napar moczopedny i przeciwzapalny. Nie mylic z chabrem blawatkiem (blekitne kwiaty pol zbozowych).</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–X</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Laki, drogi, suche zbocza</div><div class="pe-meta-item"><strong>Roslina miodna:</strong> Tak — jeden z wazniejszych gatunkow</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-kminek.jpg" alt="Kminek" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Kminek zwyczajny</div><div class="pe-latin">Carum carvi · rodzina selerowate</div></div>
                    <div class="pe-badges"><span class="badge badge-food">jadalna</span><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Roslina dwuletnia — biale baldachy na lakach i ugorach. Nasiona (VII–VIII) to klasyczna polska przyprawa do chleba, bigosu, kapusty, serow. Herbata z kminku — najlepsza na kolki niemowlece i wzdecia. Zawiera karwon i limonen. Jeden z najstarszych gatunkow uprawnych w Polsce.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> V–VII (2. rok)</div><div class="pe-meta-item"><strong>Zbior nasion:</strong> VII–VIII</div><div class="pe-meta-item"><strong>Kulinaria:</strong> Chleb, kapusta, bigos, ser twarogowy</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-marchew.jpg" alt="Marchew dzika" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Marchew zwyczajna (dzika)</div><div class="pe-latin">Daucus carota · rodzina selerowate</div></div>
                    <div class="pe-badges"><span class="badge badge-food">jadalna</span><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Dziki przodek marchwi ogrodowej. Biale baldachy z charakterystycznym purpurowym kwiatkiem posrodku. Cienki korzen jadalny przed kwitnieniem. Nasiona stosowane moczopednie i przy zaburzeniach trawienia. Bogate w beta-karoten. Roslina dwuletnia — rosnie na suchych lakach i przydrożach.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–VIII</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Suche laki, przydroża, ugory</div><div class="pe-meta-item"><strong>Zbior:</strong> Korzen przed kwitnieniem (1. rok)</div></div>
                <div class="pe-warn">UWAGA: Nie mylic z silnie trujacym szczwolem plamistym (Conium maculatum) i szalejem (Cicuta virosa)! Marchew poznasz po zapachu marchwi i purpurowym kwiatku posrodku baldachu.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-krwawnica.jpg" alt="Krwawnica" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Krwawnica pospolita</div><div class="pe-latin">Lythrum salicaria · rodzina krwawnicowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Malownicze rozowo-purpurowe lany na mokrych lakach i brzegach wod (VI–IX). Bogata w garbniki i flawonoidy — silnie sciagajaca. Napar na biegunki (rowniez u dzieci), zapalenia jamy ustnej, plukanie ran i skory. Jedna z najskuteczniejszych polskich roslin sciagajacych.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–IX</div><div class="pe-meta-item"><strong>Surowiec:</strong> Ziele (VI–VIII)</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Mokre laki, bagna, brzegi rzek</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-driakiew.jpg" alt="Driakiew" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Driakiew polna</div><div class="pe-latin">Knautia arvensis · rodzina szczeciowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Liliowoniebieskie kuliste kwiatostany na suchych lakach i przydrożach (VI–X). Jedna z piekniejszych roslin polskich lak. Wazna roslina miodna dla pszczol i motyli. Napar z korzenia i ziela stosowany na choroby skory, egzemy, tradzik i trudno gojace sie rany.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–X</div><div class="pe-meta-item"><strong>Surowiec:</strong> Korzen, ziele</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Suche laki, przydroža, zbocza</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-szalwia.jpg" alt="Szalwia lakowa" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Szalwia lakowa</div><div class="pe-latin">Salvia pratensis · rodzina jasnotowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span><span class="badge badge-food">jadalna</span></div>
                </div>
                <div class="pe-desc">Dziki kuzyn szalwii ogrodowej — niebiesko-fioletowe kwiaty zdobia suche laki i zbocza wapienne. Aromat zbliżony do szalwii lekarskiej. Napar antyseptyczny, wyrztuśny i regulujacy pocenie. Liscie do gotowania i herbat. Stosowana na anginy, stany zapalne dziasel i jamy ustnej.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> V–VIII</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Suche laki, skarpy wapienne</div><div class="pe-meta-item"><strong>Kulinaria:</strong> Do zup, herbat, naparow</div></div>
                <div class="pe-warn">Olej zawiera tujon — nie stosowac w ciazy i przy padaczce.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-mydlnica.jpg" alt="Mydlnica" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Mydlnica lekarska</div><div class="pe-latin">Saponaria officinalis · rodzina gozdzikokwatowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Rozowe kwiaty przy drogach i na brzegach lasow (VI–IX). Korzen i liscie zawieraja saponiny — pieniace sie w wodzie jak mydlo. Historycznie uzywana do prania delikatnych tkanin i welny. Napar wyrztuśny na zapalenie oskrzeli. Zewnetrznie na luszczyc i egzemy.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–IX</div><div class="pe-meta-item"><strong>Surowiec:</strong> Korzen (wiosna/jesien), ziele</div><div class="pe-meta-item"><strong>Historia:</strong> Naturalne mydlo do prania welny</div></div>
                <div class="pe-warn">Saponiny moga draznic blony sluzowe — nie przekraczac zalecanych dawek w naparach wewnetrznych.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-lnica.jpg" alt="Lnica" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Lnica pospolita (lwia paszcza polna)</div><div class="pe-latin">Linaria vulgaris · rodzina babkowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Zolte kwiatki z pomaranczowa plamka — jak miniatura lwiej paszczy. Bardzo pospolita na przydrożach, torach kolejowych i ugorach (VI–X). Ziele stosowane zewnetrznie na hemoroidy, egzemy i trudno gojace sie rany. Napar moczopedny i przeczyszczajacy w malych dawkach.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–X</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Przydroža, tory, suche ugory</div><div class="pe-meta-item"><strong>Zastosowanie:</strong> Glownie zewnetrzne</div></div>
                <div class="pe-warn">Nie stosowac wewnetrznie w duzych dawkach — toksyczna przy przedawkowaniu. Glowne zastosowanie to zewnetrzne masci i oklady.</div>
            </div>
        </div>
'@

# ===== WIOSNA — 4 rosliny (insert before line 295 = index 294) =====
$blk_wiosna = @'
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-wiazowka.jpg" alt="Wiazowka" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Wiazowka blotna (tawula)</div><div class="pe-latin">Filipendula ulmaria · rodzina rozowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span><span class="badge badge-food">jadalna</span></div>
                </div>
                <div class="pe-desc">Wyniosla roslina mokrych lak z kremowymi, intensywnie pachnacymi kwiatami (VI–VIII). Zawiera salicylany — naturalna aspiryna. Napary na goraczke, bole glowy, reumatyzm, zgage i stany zapalne. Kwiaty aromatyzuja napoje, dżemy i syropy. Dawniej aromatyzowala mid pitny.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> VI–VIII</div><div class="pe-meta-item"><strong>Surowiec:</strong> Kwiaty, ziele</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Mokre laki, brzegi rzek, rowy</div></div>
                <div class="pe-warn">Zawiera salicylany — nie stosowac przy alergii na aspiryne i u dzieci ponizej 12. roku zycia.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-gorczyca.jpg" alt="Gorczyca polna" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Gorczyca polna</div><div class="pe-latin">Sinapis arvensis · rodzina kapustowate</div></div>
                    <div class="pe-badges"><span class="badge badge-food">jadalna</span></div>
                </div>
                <div class="pe-desc">Pospolity chwast pol zbozowych i ugorow — zolte kwiaty zloca pola od kwietnia do lipca. Mlode liscie jadalne — pikantne jak rukola, do saladek i zup. Nasiona mielone jako musztarda polna. Bogata w glukozynolany o wlasciwosciach prozdrowotnych. Bardzo pospolita — latwa do znalezienia.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> IV–VII</div><div class="pe-meta-item"><strong>Kulinaria:</strong> Liscie do saladek, nasiona jako przyprawa</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Pola, ugory, zbocza</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-wyka.jpg" alt="Wyka ptasia" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Wyka ptasia</div><div class="pe-latin">Vicia cracca · rodzina bobowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Wijaca sie roslina pnaca z fioletowymi kwiatostanami. Bardzo pospolita na lakach, miedzach i przydrożach. Wazna roslina miodna i pastewna. Napar z ziela stosowany w medycynie ludowej na rany i stany zapalne skory. Nasiona trujace w wiekszych ilosciach — nie spozywa sie.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> V–VIII</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Laki, przydroža, zarosla</div><div class="pe-meta-item"><strong>Roslina miodna:</strong> Tak — pszczoly, trzmiele</div></div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-pieciornik.jpg" alt="Pieciornik gesi" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Pieciornik gesi (srebrnik)</div><div class="pe-latin">Argentina anserina · rodzina rozowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span><span class="badge badge-food">jadalna</span></div>
                </div>
                <div class="pe-desc">Rozeslana roslina o srebrzyście owlosionych lisciach (stad „srebrnik"). Zolte kwiatki na wilgotnych przydrożach i lakach. Liscie w naparze silnie sciagajace — na biegunki, stany zapalne jamy ustnej, bolene miesiaczkowanie. Korzenie jadalne gotowane. Bardzo pospolita na przydrożach i lakach.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> V–VIII</div><div class="pe-meta-item"><strong>Surowiec:</strong> Ziele kwitnace, korzen</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Wilgotne przydroža, skarpy, laki</div></div>
            </div>
        </div>
'@

# ===== WCZESNA WIOSNA — 3 rosliny (insert before line 175 = index 174) =====
$blk_wczesna = @'
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-kniec.jpg" alt="Kniec blotna" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Kniec blotna (kaczeniec)</div><div class="pe-latin">Caltha palustris · rodzina jaskrowate</div></div>
                    <div class="pe-badges"><span class="badge badge-toxic">trujaca (surowa)</span></div>
                </div>
                <div class="pe-desc">Jeden z pierwszych wiosennych kwiatow na wilgotnych lakach i brzegach wod. Lsnace zolte kwiaty (III–V) zwiastuja wiosne. Surowa roslina zawiera protoanemonine — draznaca i toksyczna substancje. Historycznie paki kwiatowe marynowano jak kapary (po gotowaniu toksyna znika). Rosnie nad strumieniami i na mokrych lakach.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> III–V</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Brzegi strumieni, mokre laki, bagna</div><div class="pe-meta-item"><strong>Tradycja:</strong> Paki kwiatowe marynowane jak kapary (po ugotowaniu)</div></div>
                <div class="pe-warn">Surowa roslina trujaca (protoanemonina). Gotowanie neutralizuje toksyne. Nie spozywa sie surowych lisci ani kwiatow.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-pierwiosnek.jpg" alt="Pierwiosnek" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Pierwiosnek lekarski (klucze sw. Piotra)</div><div class="pe-latin">Primula veris · rodzina pierwiosnkowate</div></div>
                    <div class="pe-badges"><span class="badge badge-med">lecznicza</span><span class="badge badge-prot">chroniona</span></div>
                </div>
                <div class="pe-desc">Wczesnowiosenny kwiat suchych lak i skrajow lasow. Zolte kwiaty zwisajace w charakterystyczny sposob — intensywny, slodki zapach. Korzen bogaty w saponiny i glikozydy — wyrztuśny (syrop na kaszel, zapalenie oskrzeli). Kwiaty jadalne i do herbaty. Gatunek objetyczny ochrona czesciowa w Polsce.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Kwitnienie:</strong> IV–V</div><div class="pe-meta-item"><strong>Surowiec:</strong> Korzen (jesien), kwiaty (wiosna)</div><div class="pe-meta-item"><strong>Dzialanie:</strong> Wyrztuśne, napotne, moczopedne</div></div>
                <div class="pe-warn">Gatunek objetyczny ochrona czesciowa — zbierac tylko z licznych stanowisk i z umiarem.</div>
            </div>
        </div>
        <div class="plant-entry">
            <div class="pe-photo"><img src="media/laka-czosnek-n.jpg" alt="Czosnek niedzwiedzi" loading="lazy" onerror="this.style.display='none';var n=this.nextElementSibling;if(n)n.style.display='flex'"><div class="no-photo" style="display:none"></div></div>
            <div class="pe-body">
                <div class="pe-head">
                    <div><div class="pe-name">Czosnek niedzwiedzi</div><div class="pe-latin">Allium ursinum · rodzina amarylkowate</div></div>
                    <div class="pe-badges"><span class="badge badge-food">jadalna</span><span class="badge badge-med">lecznicza</span></div>
                </div>
                <div class="pe-desc">Jeden z najcenniejszych wiosennych darow lasu. Intensywny zapach czosnku — biale kwiaty pokrywajace wilgotne lasy lisciaste (IV–V). Liscie to naturalny antybiotyk — pesto, maslo czosnkowe, zupy, salatki. Obniža cisnienie krwi i cholesterol. Silniejszy od czosnku ogrodowego.</div>
                <div class="pe-meta"><div class="pe-meta-item"><strong>Zbior lisci:</strong> III–V (przed kwitnieniem)</div><div class="pe-meta-item"><strong>Kwitnienie:</strong> IV–V</div><div class="pe-meta-item"><strong>Siedlisko:</strong> Wilgotne lasy lisciaste, doliny rzek</div></div>
                <div class="pe-warn">NIEBEZPIECZNA POMYLKA: Przed kwitnieniem liscie sa bardzo podobne do konwalii majowej (silnie trujacej!) i ciemiernicy. Zawsze sprawdz zapach — czosnek niedzwiedzi WYRANIE pachnie czosnkiem po roztarciu.</div>
            </div>
        </div>
'@

# Insert from bottom to top (to preserve indices)
Write-Host "Wczytywanie pliku... $($lines.Length) linii"

$lines = InsertAt $lines 802 $blk_toks
Write-Host "Dodano: Konwalia (toksyczne, przed linia 803)"

$lines = InsertAt $lines 674 $blk_jesien
Write-Host "Dodano: Nawloc kanadyjska (jesien, przed linia 675)"

$lines = InsertAt $lines 593 $blk_lato
Write-Host "Dodano: 11 roslin letnich (przed linia 594)"

$lines = InsertAt $lines 296 $blk_wiosna
Write-Host "Dodano: 4 rosliny wiosenne (przed linia 297)"

$lines = InsertAt $lines 176 $blk_wczesna
Write-Host "Dodano: 3 rosliny wczesnej wiosny (przed linia 177)"

# Update count-strip (file uses Polish ó in gatunków)
$lines = $lines | ForEach-Object { $_ -replace '<strong>55\+</strong>', '<strong>75+</strong>' }

[IO.File]::WriteAllLines($file, $lines, $utf8noBOM)
Write-Host "Zapisano plik. Nowa liczba linii: $($lines.Length)"
