/**
 * Manual type definitions for Supabase tables used by the two pilot API files.
 * Derived by reading api/health.js, api/user-data.js, api/_lib/paywall.js,
 * api/stripe-webhook.js, and tests/integration/user-data.test.js.
 *
 * Shape mirrors the Supabase-generated Database generic so that
 * SupabaseClient<Database> picks up column names and types.
 *
 * Columns marked `| null` reflect optional / nullable DB columns.
 * The `Relationships` array is required by GenericTable but is always empty
 * here — we do not model FK relationships in this pilot.
 */

export interface Database {
  public: {
    Tables: {
      /**
       * Users table.
       * Columns confirmed from:
       *   api/user-data.js  — email, agent_name
       *   api/_lib/paywall.js — email, subscription_tier, agent_runs_used
       *   api/stripe-webhook.js — email, subscription_tier, stripe_customer_id,
       *                           stripe_subscription_id, agent_runs_used,
       *                           agent_runs_reset_at, monthly_compute_used
       *   tests/integration/user-data.test.js — email, agent_name
       */
      users: {
        Row: {
          email: string;
          agent_name: string | null;
          subscription_tier: 'founding' | 'hunter' | 'investor' | 'operator' | string | null;
          stripe_customer_id: string | null;
          stripe_subscription_id: string | null;
          agent_runs_used: number | null;
          agent_runs_reset_at: string | null;
          monthly_compute_used: number | null;
          bonus_runs: number | null;
        };
        Insert: {
          email: string;
          agent_name?: string | null;
          subscription_tier?: string | null;
          stripe_customer_id?: string | null;
          stripe_subscription_id?: string | null;
          agent_runs_used?: number | null;
          agent_runs_reset_at?: string | null;
          monthly_compute_used?: number | null;
          bonus_runs?: number | null;
        };
        Update: Partial<Database['public']['Tables']['users']['Insert']>;
        Relationships: [];
      };

      /**
       * deal_searches table — one row per scan run.
       * Columns confirmed from api/user-data.js select: id, buy_box, status, run_at, user_email.
       */
      deal_searches: {
        Row: {
          id: string;
          user_email: string;
          buy_box: string | null;
          status: string | null;
          run_at: string | null;
        };
        Insert: {
          id?: string;
          user_email: string;
          buy_box?: string | null;
          status?: string | null;
          run_at?: string | null;
        };
        Update: Partial<Database['public']['Tables']['deal_searches']['Insert']>;
        Relationships: [];
      };

      /**
       * conversations table — scan debriefs and deal Q&A threads.
       * Columns confirmed from api/user-data.js selects:
       *   id, search_id, conversation_type, user_email, deal_id.
       */
      conversations: {
        Row: {
          id: string;
          user_email: string;
          conversation_type: 'scan_debrief' | 'deal_qa' | string | null;
          search_id: string | null;
          deal_id: string | null;
        };
        Insert: {
          id?: string;
          user_email: string;
          conversation_type?: string | null;
          search_id?: string | null;
          deal_id?: string | null;
        };
        Update: Partial<Database['public']['Tables']['conversations']['Insert']>;
        Relationships: [];
      };

      /**
       * deals table — individual deal listings attached to a scan.
       * Columns confirmed from api/user-data.js select:
       *   id, title, location, price, acreage, rooms_keys, score_breakdown,
       *   source, url, search_id, passed_hard_filters, brief,
       *   days_on_market, property_type, raw_description.
       */
      deals: {
        Row: {
          id: string;
          search_id: string | null;
          title: string | null;
          location: string | null;
          price: number | null;
          acreage: number | null;
          rooms_keys: number | null;
          score_breakdown: Record<string, unknown> | null;
          source: string | null;
          url: string | null;
          passed_hard_filters: boolean | null;
          brief: string | null;
          days_on_market: number | null;
          property_type: string | null;
          raw_description: string | null;
          deal_status:
            | 'new'
            | 'reviewing'
            | 'contacted'
            | 'financials'
            | 'loi'
            | 'under_contract'
            | 'closed'
            | 'passed'
            | null;
        };
        Insert: {
          id?: string;
          search_id?: string | null;
          title?: string | null;
          location?: string | null;
          price?: number | null;
          acreage?: number | null;
          rooms_keys?: number | null;
          score_breakdown?: Record<string, unknown> | null;
          source?: string | null;
          url?: string | null;
          passed_hard_filters?: boolean | null;
          brief?: string | null;
          days_on_market?: number | null;
          property_type?: string | null;
          raw_description?: string | null;
          deal_status?: string | null;
        };
        Update: Partial<Database['public']['Tables']['deals']['Insert']>;
        Relationships: [];
      };

      /**
       * user_deal_stars — tracks which deals a user has starred.
       * Columns confirmed from api/user-data.js: deal_id, user_email.
       */
      user_deal_stars: {
        Row: {
          user_email: string;
          deal_id: string;
        };
        Insert: {
          user_email: string;
          deal_id: string;
        };
        Update: Partial<Database['public']['Tables']['user_deal_stars']['Insert']>;
        Relationships: [];
      };

      /**
       * user_deal_views — tracks which deals a user has viewed.
       * Columns confirmed from api/user-data.js: deal_id, user_email.
       */
      user_deal_views: {
        Row: {
          user_email: string;
          deal_id: string;
        };
        Insert: {
          user_email: string;
          deal_id: string;
        };
        Update: Partial<Database['public']['Tables']['user_deal_views']['Insert']>;
        Relationships: [];
      };

      /**
       * user_deal_archives — tracks which deals a user has archived.
       * Columns confirmed from api/user-data.js: deal_id, user_email.
       */
      user_deal_archives: {
        Row: {
          user_email: string;
          deal_id: string;
        };
        Insert: {
          user_email: string;
          deal_id: string;
        };
        Update: Partial<Database['public']['Tables']['user_deal_archives']['Insert']>;
        Relationships: [];
      };
    };
    Views: Record<string, never>;
    Functions: {
      increment_agent_runs: {
        Args: { p_email: string; p_amount: number };
        Returns: null;
      };
      increment_bonus_runs: {
        Args: { p_email: string; p_amount: number };
        Returns: null;
      };
    };
    Enums: Record<string, never>;
  };
}
