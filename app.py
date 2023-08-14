# -*- coding: utf-8 -*-
"""
Created on Tue Jul 25 15:45:25 2023

@author: Tnluser
"""

import pandas as pd
import streamlit as st
import pickle
import requests

movies_dict = pickle.load(open('movies_dict.pkl','rb'))
movies = pd.DataFrame(movies_dict)
similarity = pickle.load(open('similarity.pkl','rb'))

def fetch_poster(movie_id):
    response = requests.get("https://api.themoviedb.org/3/movie/{}?api_key=68118c8291c55576d6ff59219045e808".format(movie_id))
    data = response.json()
    return "https://image.tmdb.org/t/p/w500" + data['poster_path']


def recommend(movie):
    movie_index = movies[movies['title'] == movie].index[0]
    distances = similarity[movie_index]
    movies_list = sorted(list(enumerate(distances)),reverse = True, key = lambda x:x[1])[1:6]
    Recommended_movies = []
    Recommended_movie_posters = []
    for i in movies_list:
        Recommended_movies.append(movies.iloc[i[0]]['title'])
        Recommended_movie_posters.append(fetch_poster(movies.iloc[i[0]]['id']))
    return Recommended_movies, Recommended_movie_posters    

st.title("Movie Recommender System")
selected_movie_name = st.selectbox('Pick your favourite movie', movies['title'].values)
if st.button('Click me'):
    name, posters = recommend(selected_movie_name)
    col1, col2, col3, col4, col5 = st.columns(5)
    
    with col1:
        st.text(name[0])
        st.image(posters[0])
        
    with col2:
        st.text(name[1])
        st.image(posters[1])
        
    with col3:
        st.text(name[2])
        st.image(posters[2])
        
    with col4:
        st.text(name[3])
        st.image(posters[3])
        
    with col5:
        st.text(name[4])
        st.image(posters[4])        