% sadi uysal    
% 2015400162
% compiling: yes
% complete: yes

% artist(ArtistName, Genres, AlbumIds).
% album(AlbumId, AlbumName, ArtistNames, TrackIds).
% track(TrackId, TrackName, ArtistNames, AlbumName, [Explicit, Danceability, Energy,
%                                                   Key, Loudness, Mode, Speechiness,
%                                                   Acousticness, Instrumentalness, Liveness,
%                                                   Valence, Tempo, DurationMs, TimeSignature]).





%putcart(CargoList,Carts):-
    putcartHelper(CargoList,Carts,150,[]).

%putcartHelper([ ],[Cart|Carts],_,Cart).
%putcartHelper([cargo(W)|Tail],Carts,Remsize,Cart):-

    (Remsize-W=<0,
    putcartHelper([cargo(W)|Tail],[Cart|Carts],150,[]))
    ;
    (Remsize-W>=0,
    putcartHelper(Tail,Carts,Remsize-W,[cargo(W)|Cart])).






%HELPER FUNCTIONS












features([explicit-0, danceability-1, energy-1,
          key-0, loudness-0, mode-1, speechiness-1,
       	  acousticness-1, instrumentalness-1,
          liveness-1, valence-1, tempo-0, duration_ms-0,
          time_signature-0]).

filter_features(Features, Filtered) :- features(X), filter_features_rec(Features, X, Filtered).
filter_features_rec([], [], []).
filter_features_rec([FeatHead|FeatTail], [Head|Tail], FilteredFeatures) :-
    filter_features_rec(FeatTail, Tail, FilteredTail),
    _-Use = Head,
    (
        (Use is 1, FilteredFeatures = [FeatHead|FilteredTail]);
        (Use is 0,
            FilteredFeatures = FilteredTail
        )
    ).


appendFunc([],L,L).    %appends two lists into one list.
appendFunc([H|T],L2,[H|L3])  :-  append(T,L2,L3).

list_sum([],[],[]).    %finds sums of corresponding indexes and put into list 
list_sum([H1|T1],[H2|T2],[X|L3]):-
    list_sum(T1,T2,L3), 
    X is H1+H2.

divide_by_k([], _, []).   %divides lists elements by k 
divide_by_k([Head|Tail], K, Result) :-
    Y is Head / K,
    divide_by_k(Tail, K, ResultTail),
    Result = [Y|ResultTail].


getTrackNames([],[]).     %gets trackNames for given TrackIds 
getTrackNames([TrackId|TrackIds],RESULT):-
    track(TrackId,TrackName,_,_,_),
    getTrackNames(TrackIds,Result),
    appendFunc([TrackName],Result,RESULT).

getTrackIds([ ],[ ]).     %gets trackIds for given AlbumIds
getTrackIds([AlbumId|AlbumIds],RESULT):-
    album(AlbumId,_,_,TrackIds),
    getTrackIds(AlbumIds,Result),
    appendFunc(TrackIds,Result,RESULT).

getFeaturesSum([ ],[0,0,0,0,0,0,0,0],0).   %finds features sum for given TracksIDs and puts into RESULT
getFeaturesSum([TrackId|TrackIds],RESULT,Size):-
    track(TrackId, _, _, _, [_, Danceability, Energy,
                                                   _, _, Mode, Speechiness,
                                                   Acousticness, Instrumentalness, Liveness,
                                                   Valence, _, _, _]),
    getFeaturesSum(TrackIds,Result,CSize),
    Size=CSize+1,
    list_sum([Danceability,Energy,Mode,Speechiness,Acousticness,Instrumentalness,Liveness,Valence],Result,RESULT).


euclideanD([P|PList], [Q|QList], Dist) :-   %finds euclidean distance between lists
        distanceSum(PList, QList, (P-Q)^2, R),
        Dist is sqrt(R).

distanceSum([], [], V, V).
distanceSum([P|PList], [Q|QList], V0, V+V0) :-
        distanceSum(PList, QList, (P-Q)^2, V).


getArtistGenres([],[]).        %finds Artist Genres and put into Genres
getArtistGenres([ArtistName|ArtistNames],Genres):-
    artist(ArtistName,Genre,_),
    getArtistGenres(ArtistNames,RemainGenres),
    appendFunc(Genre,RemainGenres,Genres).


takeFirstN([_|_],0,[],[]).  %takes first N importantant fetures for findMostSimilarAlbums and findMostSimilarTracks
takeFirstN([[Id,_,Name]|Tail1],N,[Id|List],[Name|List2]):-
    N>=0,
    NewN is N-1,
    takeFirstN(Tail1,NewN,List,List2).

takeFirstNArtistList([_|_],0,[]).   %takes first N importantant fetures for findMostSimilarArtists
takeFirstNArtistList([[Name,_]|Tail1],N,[Name|List]):-
    N>=0,
    NewN is N-1,
    takeFirstNArtistList(Tail1,NewN,List).


checkListSubstring([],_,0). %checks whether given list has the substring or not (Success=1,Fail=0)
checkListSubstring([Str|List],Subs,Result):-
    (sub_string(Str,_, _, _, Subs),Result=1);
    checkListSubstring(List,Subs,Result).

trackEliminatorLikedGenre([],[]). %searches tracks according to given liked genres and puts into Tracks
trackEliminatorLikedGenre([Genre|Genres],Tracks):-   
    findall(TrackId,(track(TrackId,_, _, _, _),getTrackGenre(TrackId,CurrGenres),checkListSubstring(CurrGenres,Genre,Result),Result==1),CurrTracks),
    trackEliminatorLikedGenre(Genres,RemainTracks),
    union(CurrTracks,RemainTracks,Tracks).

trackEliminatorDisLikedGenre([],_,[]). %finds tracks with Disliked genres in the Candidate Tracks and puts into EliminatedTracks
trackEliminatorDisLikedGenre([Genre|Genres],CandidateTracks,EliminatedTracks):-   
    findall(TrackId,(member(TrackId,CandidateTracks),getTrackGenre(TrackId,CurrGenres),checkListSubstring(CurrGenres,Genre,Result),Result==1),CurrEliminatedTracks),
    trackEliminatorDisLikedGenre(Genres,CandidateTracks,RemainEliminatedTracks),
    union(CurrEliminatedTracks,RemainEliminatedTracks,EliminatedTracks).

takeFirstNPlaylist([_|_],0,[],[],[],[]).   %takes first N importantant fetures for discoverPlaylist
takeFirstNPlaylist([[TrackId,Distance,TrackName,ArtistName]|Tail1],N,[TrackId|List],[TrackName|List2],[ArtistName|List3],[Distance|List4]):-
    N>=0,
    NewN is N-1,
    takeFirstNPlaylist(Tail1,NewN,List,List2,List3,List4).


getCandidateInfos([],_,[]).  %gets important informations about the CandidateTracks and puts into Infos 
getCandidateInfos([TrackId|CandidateTracks],Features,Infos):-
    track(TrackId,TrackName,ArtistName, _,TFeatures),
    filter_features(TFeatures,FFeatures),
    euclideanD(FFeatures,Features,Score),
    getCandidateInfos(CandidateTracks,Features,RemainInfos),
    appendFunc([[TrackId,Score,TrackName,ArtistName]],RemainInfos,Infos).






%Description Functions

%all functions used here explained above

getArtistTracks(ArtistName, TrackIds, TrackNames):-  
    artist(ArtistName,_,AlbumIds),
    getTrackIds(AlbumIds,TrackIds),
    getTrackNames(TrackIds,TrackNames).
    
albumFeatures(AlbumId, AlbumFeatures):-
    album(AlbumId, _,_, TrackIds),
    getFeaturesSum(TrackIds,Sum,Size),
    divide_by_k(Sum,Size,AlbumFeatures).

artistFeatures(ArtistName, ArtistFeatures):-
    artist(ArtistName,_,AlbumIds),
    getTrackIds(AlbumIds,TrackIds),
    getFeaturesSum(TrackIds,Sum,Size),
    divide_by_k(Sum,Size,ArtistFeatures).


trackDistance(TrackId1, TrackId2, Score):-
    track(TrackId1, _, _, _, Features1),
    track(TrackId2, _, _, _, Features2),
    filter_features(Features1,FFeatures1),
    filter_features(Features2,FFeatures2),
    euclideanD( FFeatures1,FFeatures2,Score).


albumDistance(AlbumId1, AlbumId2, Score):-
    albumFeatures(AlbumId1,AlbumFeatures1),
    albumFeatures(AlbumId2,AlbumFeatures2),
    euclideanD(AlbumFeatures1,AlbumFeatures2,Score).

artistDistance(ArtistName1, ArtistName2, Score) :-
    artistFeatures(ArtistName1,ArtistFeatures1),
    artistFeatures(ArtistName2,ArtistFeatures2),
    euclideanD( ArtistFeatures1,ArtistFeatures2,Score).

findMostSimilarTracks(TrackId,  SimilarIds, SimilarNames):-   %finds all track distances,put into Pairs then sort, take first 30.
    findall([TrackId2,Score,TrackName2],(track(TrackId2,TrackName2, _, _, _),trackDistance(TrackId,TrackId2,Score),\+ TrackId=TrackId2),Pairs),
    sort(2, @=<, Pairs, OrderedPairs),
    takeFirstN(OrderedPairs,30,SimilarIds,SimilarNames).
    


findMostSimilarAlbums(AlbumId, SimilarIds, SimilarNames):-   %finds all album distances,put into Pairs then sort, take first 30.
    findall([AlbumId2,Score,AlbumName2],(album(AlbumId2,AlbumName2, _, _),albumDistance(AlbumId,AlbumId2,Score),\+ AlbumId=AlbumId2),Pairs),
    sort(2, @=<, Pairs, OrderedPairs),
    takeFirstN(OrderedPairs,30,SimilarIds,SimilarNames).


findMostSimilarArtists(ArtistName, SimilarArtists):-     %finds all artist distances,put into Pairs then sort, take first 30.
    findall([ArtistName2,Score],(artist(ArtistName2,_, _),artistDistance(ArtistName,ArtistName2,Score),\+ ArtistName=ArtistName2),Pairs),
    sort(2, @=<, Pairs, OrderedPairs),
    takeFirstNArtistList(OrderedPairs,30,SimilarArtists).


filterExplicitTracks(TrackList, FilteredTracks):-     %finds all not explicit tracks and put into FilteredTracks
    findall(TrackId,(member(TrackId,TrackList),track(TrackId,_,_,_,[Explicit,_,_,_,_,_,_,_,_,_,_,_,_,_]),Explicit=<0),FilteredTracks).
    
getTrackGenre(TrackId, Genres):-
    track(TrackId,_,ArtistNames,_,_),
    getArtistGenres(ArtistNames,GenreList),
    list_to_set(GenreList,Genres).

discoverPlaylist(LikedGenres, DislikedGenres, Features,Filename, Playlist) :- 
    trackEliminatorLikedGenre(LikedGenres,CandidateTracks),
    trackEliminatorDisLikedGenre(DislikedGenres,CandidateTracks,EliminatedTracks),
    subtract(CandidateTracks, EliminatedTracks, Tracks),  %subtract EliminatedTracks from CandidateTracks and put into Tracks
    list_to_set(Tracks,TracksSet),                          %removes duplicates
    getCandidateInfos(TracksSet,Features,Infos),
    sort(2, @=<, Infos, OrderedInfos),                          %sort according to second columns which is Distance Score
    takeFirstNPlaylist(OrderedInfos,30,Playlist,Names,Artists,Distances),    %take first 30
    open(Filename, write, Stream), 
    %writeln(Stream, "TrackIDs = "), 
    writeln(Stream, Playlist), 
    %writeln(Stream, "TrackNames = "), 
    writeln(Stream, Names), 
    %writeln(Stream, "Artist's Names = "), 
    writeln(Stream, Artists), 
    %writeln(Stream, "Distance Scores = "), 
    writeln(Stream, Distances), 
    close(Stream).


%filter_features(Features, Filtered)
