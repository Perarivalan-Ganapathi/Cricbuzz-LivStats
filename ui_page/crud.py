import streamlit as st
import pymysql

def connect_pymysql():
    return pymysql.connect(
        host="localhost",
        user="root",
        password="0406",
        database="db1",
        port=3306,
        cursorclass=pymysql.cursors.DictCursor
    )


def crud():
    st.title("🛠️ CRUD Operations with MySQL")

    conn = connect_pymysql()
    cursor = conn.cursor()

    crud_option = st.selectbox(
        "Select Operation",
        ["➕ Create", "📖 Read", "✏️ Update", "🗑️ Delete"]
    )


    if crud_option == "➕ Create":
        st.subheader("Add a New Player")

        with st.form("create_form", clear_on_submit=True):
            col1, col2 = st.columns(2)
            with col1:
                player_id = st.number_input("Player Id", min_value=1)
                name = st.text_input("Batsman Name")
                matches = st.number_input("Matches Played", min_value=0)
            with col2:
                innings = st.number_input("Total Innings", min_value=0)
                runs = st.number_input("Runs", min_value=0)
                average = st.number_input("Average", min_value=0.0, format="%.2f")

            submitted = st.form_submit_button("Insert")

            if submitted:
                try:
                    cursor.execute(
                        """
                        INSERT INTO crud(player_id, batter, matches, innings, runs, average)
                        VALUES (%s, %s, %s, %s, %s, %s)
                        """,
                        (player_id, name, matches, innings, runs, average)
                    )
                    conn.commit()
                    st.success(f"🎉 Player **{name}** added successfully!")
                except Exception as e:
                    conn.rollback()
                    st.error(f"⚠️ Error: {e}")



    elif crud_option == "📖 Read":
        st.subheader("All Players")

        try:
            cursor.execute("SELECT * FROM crud")
            rows = cursor.fetchall()

            if rows:
                st.table(rows)
            else:
                st.info("No players found in the database.")

        except Exception as e:
            st.error(f"⚠️ Error: {e}")


    elif crud_option == "✏️ Update":
        st.subheader("Update Player Details")

        player_id = st.number_input("Enter Player ID to Update", min_value=1)

        if st.button("Fetch Player"):
            try:
                cursor.execute("SELECT * FROM crud WHERE player_id = %s", (player_id,))
                player = cursor.fetchone()

                if player:
                    st.write("🔹 Current Details:", player)

                    with st.form("update_form"):
                        name = st.text_input("Batsman Name", player["batter"])
                        matches = st.number_input("Matches Played", value=player["matches"])
                        innings = st.number_input("Total Innings", value=player["innings"])
                        runs = st.number_input("Runs", value=player["runs"])
                        average = st.number_input("Average", value=float(player["average"]), format="%.2f")

                        submitted = st.form_submit_button("Update")

                        if submitted:
                            cursor.execute(
                                """
                                UPDATE crud
                                SET batter=%s, matches=%s, innings=%s, runs=%s, average=%s
                                WHERE player_id=%s
                                """,
                                (name, matches, innings, runs, average, player_id)
                            )
                            conn.commit()
                            st.success(f"✅ Player ID {player_id} updated successfully!")
                else:
                    st.warning("⚠️ Player not found.")

            except Exception as e:
                st.error(f"⚠️ Error: {e}")


    elif crud_option == "🗑️ Delete":
        st.subheader("Delete a Player")

        player_id = st.number_input("Enter Player ID to Delete", min_value=1)

        if st.button("Delete"):
            try:
                cursor.execute("DELETE FROM crud WHERE player_id = %s", (player_id,))
                conn.commit()

                if cursor.rowcount > 0:
                    st.success(f"🗑️ Player ID {player_id} deleted successfully!")
                else:
                    st.warning("⚠️ Player not found.")

            except Exception as e:
                st.error(f"⚠️ Error: {e}")


    cursor.close()
    conn.close()