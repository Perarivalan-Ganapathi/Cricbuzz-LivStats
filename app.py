import streamlit as st
from ui_page.sql import sql_page
from ui_page.crud import crud
from ui_page.live import live_recent_matches
from ui_page.plyr_stat import pl_st

st.set_page_config(
    page_title="Cricbuzz LiveStats",
    layout="wide",
    page_icon="🏏"
)


st.markdown("""
    <style>
    /* ---------- General Layout ---------- */
    .main {
        background-color: var(--background-color);
    }
    .title-text {
        font-size: 36px;
        font-weight: 700;
        color: #00bfa5;
    }
    .subtitle {
        font-size: 18px;
        color: var(--text-color);
        margin-top: -10px;
        margin-bottom: 20px;
    }

    /* ---------- Sidebar Styling ---------- */
    .stSidebar {
        background-color: var(--sidebar-bg);
    }

    /* ---------- Radio Button Text ---------- */
    div[data-testid="stSidebar"] div[role="radiogroup"] label p {
        color: var(--sidebar-text-color) !important;
        font-weight: 600;
        transition: color 0.2s ease-in-out;
    }

    div[data-testid="stSidebar"] div[role="radiogroup"] label:hover p {
        color: var(--sidebar-hover-color) !important;
        text-decoration: underline;
    }

    footer {visibility: hidden;}

    /* ---------- LIGHT MODE ---------- */
    @media (prefers-color-scheme: light) {
        :root {
            --background-color: #f8fafc;
            --sidebar-bg: #f0f8f5;
            --text-color: #333333;
            --sidebar-text-color: #00695c;
            --sidebar-hover-color: #004d40;
        }
    }

    /* ---------- DARK MODE ---------- */
    @media (prefers-color-scheme: dark) {
        :root {
            --background-color: #0e1117;
            --sidebar-bg: #1a1f25;
            --text-color: #e0e0e0;
            --sidebar-text-color: #26a69a;
            --sidebar-hover-color: #4db6ac;
        }
    }
    </style>
""", unsafe_allow_html=True)



st.markdown("<div style='text-align:center;'><h1 class='title-text'>🏏 Cricbuzz LiveStats</h1><p class='subtitle'>Real-time Cricket Analytics Dashboard</p></div>", unsafe_allow_html=True)
st.markdown("---")


st.sidebar.image("assets/logo.png", use_container_width=True)
st.sidebar.title("📊 Navigation Panel")
page = st.sidebar.radio(
    "Select a Section",
    ["🏟️ Live/Recent Matches", "⭐ Top Player Stats", "🧮 SQL Analytics", "🛠️ CRUD Operations"]
)

if page == "🏟️ Live/Recent Matches":
    st.subheader("🏏 Live & Recent Matches Overview")
    live_recent_matches()

elif page == "⭐ Top Player Stats":
    st.subheader("🔥 Top Player Statistics")
    pl_st()

elif page == "🧮 SQL Analytics":
    st.subheader("📈 SQL Analytics Dashboard")
    sql_page()

elif page == "🛠️ CRUD Operations":
    st.subheader("🧰 Manage Player Data")
    crud()


st.markdown("<hr>", unsafe_allow_html=True)
st.markdown("<p style='text-align:center; color:gray;'>© 2025 Cricbuzz LiveStats | Built by GP</p>", unsafe_allow_html=True)
