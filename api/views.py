from django.http import JsonResponse

from rest_framework.views import APIView

import firebase_admin
from firebase_admin import credentials, firestore

from sklearn.metrics.pairwise import cosine_similarity
from sklearn.feature_extraction.text import CountVectorizer

# TODO: Initialize Firebase
cred = credentials.Certificate("api\\assets\\play-connect-40fa6-firebase-adminsdk-azqc6-7277e63366.json")
firebase_admin.initialize_app(cred)
db = firestore.client()


# albums = ["Daaru Party", "Jalebi Baby (Tesher x Jason Derulo)", "It's About Us", "Chibi Ninja Sessions: Music from Naruto Shippuden", "Battlecry"]
# tracks = ["Daaru Party", "Jalebi Baby (Tesher x Jason Derulo)", "Broken Frame", "Sasuke's Childhood (Peaceful Theme)",  "Victory"]
# genres = ["desi pop", "filmi", "indian instrumental", "modern bollywood", "classic bollywood" "afghan pop", "chutney" , "indian singer-songwriter"]
# artists = ["Pritam", "Kishore Kumar", "Kumar Sanu", "Jatin-Lalit", "Udit Narayan"]

# albums1 = [ "Warmer In The Winter (Deluxe Edition)", "Two Steps from Hell", "Itachi's Theme", "This Is Acting", "Dhoom:3"]
# tracks1 = ["Carol Of The Bells", "Star Sky", "Itachi's Theme", "Unstoppable", "Bande Hain Hum Uske"]
# genres1 = [ "electro house", "epicore", "soundtrack", "video game music", "classic bollywood", "desi pop", "filmi", "hare krishna", "modern bollywood"]
# artists1 = ["Thomas Bergersen", "Alka Yagnik", "Jasleen Royal", "KK", "Alan Walker"]
features = ["albums", "tracks", "genres", "artists"]

# TODO: Suggest Users
class SuggestUsers(APIView):
    def post(self, request):

        
        if "user_id" not in request.data.keys():
            return JsonResponse({"success": False, "message": "'user_id' is required."}, status=400)
        id = request.data["user_id"]
        # ? Get Source User Info
        source_user = db.collection(u'Users').document(id).get().to_dict()
        source_features = { i:source_user[i] for i in features }
        # albums = source_user["albums"]
        # tracks = source_user["tracks"]
        # genres = source_user["genres"]
        # artists = source_user["artists"]

        # ? Get other users info exclude the friends of source user
        friends = []
        for following in (db.collection(u'Following').document(id).collection(u'userFollowing').stream()):
            friends.append(following.id)

        exclude = friends + [id]

        # ? Calculate scores 
        suggestions = {}
        for doc in db.collection(u'Users').stream():
            if doc.id not in exclude:
                target_features = { i:doc.to_dict()[i] for i in features }
                suggestions[doc.id] = getScore(source_features, target_features)

        # ? Sort by score in descending order
        suggestions = {k: v for k, v in sorted(suggestions.items(), key=lambda item: item[1], reverse=True)}
        return JsonResponse({"success": True, "data": suggestions}, status=200)


def getScore(source, target):
    similarities = {i : similarity(source[i], target[i]) for i in features}
    # {    
    #     "albums": similarity(albums, albums), 
    #     "tracks": similarity(tracks, tracks), 
    #     "genres": similarity(genres, genres), 
    #     "artists": similarity(artists, artists)
    # }

    weigths = {"albums": 15, "tracks": 20, "genres": 5, "artists": 10}

    return ( sum([(similarities[i]*weigths[i])  for i in features]) / sum(weigths.values()) )

def similarity(a, b):
    g1=[]
    g2=[]
    ab = []
    for i in a:
        g1.append(i)

    for j in b:
        g2.append(j)

    ab.append(' '.join(g1))
    ab.append(' '.join(g2))

    vectorizer = CountVectorizer().fit_transform(ab)
    vectors = vectorizer.toarray()
    csim = cosine_similarity(vectors)
    return csim[0][1]
