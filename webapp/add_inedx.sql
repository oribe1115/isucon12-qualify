create index competition_enant_player on player_score(`competition_id`, `tenant_id`, `player_id`, `row_num`);
